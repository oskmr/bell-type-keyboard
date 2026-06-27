#!/bin/bash

# App Store Connect - Full Submit for Review
# バージョンバンプ → アーカイブ → アップロード → バージョン作成 → リリースノート設定 → 審査提出

set -e

# ==================== 設定読み込み ====================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_ROOT="$(cd "$SKILL_DIR/.." && pwd)"
UPLOAD_SKILL_DIR="$SKILLS_ROOT/ios-appstore-upload"
CONFIG_FILE="$UPLOAD_SKILL_DIR/config/settings.conf"
SUBMIT_CONFIG_FILE="$SKILL_DIR/config/settings.conf"
API_SCRIPT="$SKILL_DIR/scripts/appstore_api.py"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: 設定ファイルが見つかりません: $CONFIG_FILE" >&2
    exit 1
fi

if [ -f "$SUBMIT_CONFIG_FILE" ]; then
    source "$SUBMIT_CONFIG_FILE"
fi

# ==================== パラメータ ====================
PROJECT_PATH="${1:-.}"
NEW_VERSION="${2:-}"
RELEASE_NOTES="${3:-}"

# ==================== 関数定義 ====================

error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

success_msg() {
    echo "OK: $1"
}

progress_msg() {
    echo ">>> $1..."
}

get_current_version() {
    local project_path="$1"
    local pbxproj=$(find "$project_path" -maxdepth 2 -name "project.pbxproj" | head -1)
    if [ -z "$pbxproj" ]; then
        error_exit "project.pbxproj が見つかりません"
    fi
    grep "MARKETING_VERSION" "$pbxproj" | head -1 | sed 's/.*= *\(.*\);/\1/' | xargs
}

get_bundle_id() {
    local project_path="$1"
    local pbxproj=$(find "$project_path" -maxdepth 2 -name "project.pbxproj" | head -1)
    grep "PRODUCT_BUNDLE_IDENTIFIER" "$pbxproj" | grep -v Tests | head -1 | sed 's/.*= *"\{0,1\}\(.*\)"\{0,1\};/\1/' | xargs | tr -d '"'
}

bump_version() {
    local project_path="$1"
    local new_version="$2"
    local pbxproj=$(find "$project_path" -maxdepth 2 -name "project.pbxproj" | head -1)
    local current_version=$(get_current_version "$project_path")

    if [ "$current_version" = "$new_version" ]; then
        success_msg "バージョンは既に $new_version です"
        return
    fi

    sed -i '' "s/MARKETING_VERSION = ${current_version};/MARKETING_VERSION = ${new_version};/g" "$pbxproj"
    success_msg "バージョンを $current_version → $new_version に更新"
}

increment_patch_version() {
    local version="$1"
    local major minor patch

    IFS='.' read -r major minor patch <<< "$version"
    patch=${patch:-0}
    minor=${minor:-0}

    patch=$((patch + 1))
    echo "${major}.${minor}.${patch}"
}

call_api() {
    local cmd="$1"
    shift
    python3 "$API_SCRIPT" "$cmd" "$API_KEY_ID" "$API_ISSUER_ID" "$API_KEY_PATH" "$@"
}

# ==================== メイン処理 ====================

main() {
    echo ""
    echo "========================================="
    echo "  App Store Review Submission"
    echo "========================================="
    echo ""

    cd "$PROJECT_PATH" || error_exit "プロジェクトパスが見つかりません: $PROJECT_PATH"

    local current_version=$(get_current_version "$PROJECT_PATH")
    local bundle_id=$(get_bundle_id "$PROJECT_PATH")

    echo "  Bundle ID:      $bundle_id"
    echo "  現在のバージョン: $current_version"

    # バージョン決定
    if [ -z "$NEW_VERSION" ]; then
        NEW_VERSION=$(increment_patch_version "$current_version")
    fi
    echo "  新バージョン:    $NEW_VERSION"
    echo ""

    # リリースノート確認
    if [ -z "$RELEASE_NOTES" ]; then
        error_exit "リリースノートが指定されていません (第3引数)"
    fi
    echo "  リリースノート:"
    echo "  ─────────────────────────"
    echo "$RELEASE_NOTES" | sed 's/^/  /'
    echo "  ─────────────────────────"
    echo ""

    # Step 1: バージョンバンプ
    echo "-----------------------------------------"
    echo "  Step 1/5: Version Bump"
    echo "-----------------------------------------"
    bump_version "$PROJECT_PATH" "$NEW_VERSION"
    echo ""

    # Step 2: アーカイブ & アップロード
    echo "-----------------------------------------"
    echo "  Step 2/5: Archive & Upload"
    echo "-----------------------------------------"
    progress_msg "アーカイブ & アップロード中（既存スキルを利用）"
    if ! bash "$UPLOAD_SKILL_DIR/scripts/appstore_upload.sh" "$PROJECT_PATH"; then
        error_exit "アーカイブ/アップロードに失敗しました"
    fi
    echo ""

    # Step 3: App ID取得 & バージョン作成
    echo "-----------------------------------------"
    echo "  Step 3/5: Create Version on App Store Connect"
    echo "-----------------------------------------"
    progress_msg "App ID を取得中"
    APP_ID=$(call_api get-app-id "$bundle_id")
    success_msg "App ID: $APP_ID"

    progress_msg "バージョン $NEW_VERSION を作成中"
    VERSION_RESULT=$(call_api create-version "$APP_ID" "$NEW_VERSION")
    VERSION_ID=$(echo "$VERSION_RESULT" | cut -d: -f2)

    if echo "$VERSION_RESULT" | grep -q "^EXISTING"; then
        success_msg "既存バージョン $NEW_VERSION を使用 (ID: $VERSION_ID)"
    else
        success_msg "バージョン $NEW_VERSION を作成 (ID: $VERSION_ID)"
    fi
    echo ""

    # Step 4: リリースノート設定
    echo "-----------------------------------------"
    echo "  Step 4/5: Set Release Notes"
    echo "-----------------------------------------"
    progress_msg "リリースノートを設定中"
    NOTES_RESULT=$(call_api set-release-notes "$VERSION_ID" "$RELEASE_NOTES")
    echo "$NOTES_RESULT" | while IFS= read -r line; do
        success_msg "ローカライゼーション: $line"
    done
    echo ""

    # Step 5: ビルド選択 & 暗号化申告
    echo "-----------------------------------------"
    echo "  Step 5/7: Select Build & Set Encryption"
    echo "-----------------------------------------"

    # ビルドが処理されるまで待機
    echo ">>> ビルド処理の完了を待機中（最大5分）..."
    local max_wait=300
    local waited=0
    local interval=15
    local BUILD_ID=""
    while [ $waited -lt $max_wait ]; do
        BUILD_LIST=$(call_api list-builds "$APP_ID")
        BUILD_ID=$(echo "$BUILD_LIST" | head -1 | cut -d: -f1)
        BUILD_STATE=$(echo "$BUILD_LIST" | head -1 | cut -d: -f3)
        if [ "$BUILD_STATE" = "VALID" ]; then
            break
        fi
        echo ">>> ビルド状態: $BUILD_STATE - ${interval}秒後に再確認..."
        sleep $interval
        waited=$((waited + interval))
    done

    if [ -z "$BUILD_ID" ]; then
        error_exit "有効なビルドが見つかりません"
    fi
    success_msg "ビルド選択: $BUILD_ID"

    progress_msg "ビルドをバージョンに紐付け中"
    call_api select-build "$VERSION_ID" "$BUILD_ID"
    success_msg "ビルド紐付け完了"

    progress_msg "暗号化申告を設定中"
    call_api set-encryption "$BUILD_ID" "false"
    success_msg "暗号化申告: usesNonExemptEncryption = false"
    echo ""

    # Step 6: 審査提出
    echo "-----------------------------------------"
    echo "  Step 6/7: Submit for Review"
    echo "-----------------------------------------"
    progress_msg "審査に提出中"
    SUBMIT_RESULT=$(call_api submit-review "$APP_ID" "$VERSION_ID")
    success_msg "審査に提出しました"
    echo "$SUBMIT_RESULT"
    echo ""

    echo "========================================="
    echo "  完了! 審査に提出されました"
    echo "========================================="
    echo ""
    echo "  バージョン: $NEW_VERSION"
    echo "  App Store Connect で確認:"
    echo "  https://appstoreconnect.apple.com"
    echo ""
}

main "$@"
