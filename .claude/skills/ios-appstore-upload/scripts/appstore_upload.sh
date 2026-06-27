#!/bin/bash

# App Store Connect Archive & Upload Script
# xcodebuild archive -> exportArchive (with upload) の自動化

set -e

# ==================== 設定読み込み ====================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SKILL_DIR/config/settings.conf"
EXPORT_OPTIONS_PLIST="$SKILL_DIR/ExportOptions.plist"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "ERROR: 設定ファイルが見つかりません: $CONFIG_FILE" >&2
    exit 1
fi

LOCAL_CONFIG_FILE="$SKILL_DIR/config/settings.local.conf"
if [ -f "$LOCAL_CONFIG_FILE" ]; then
    source "$LOCAL_CONFIG_FILE"
fi

# ==================== パラメータ ====================
PROJECT_PATH="${1:-.}"
SCHEME="${2:-$DEFAULT_SCHEME}"
ARCHIVE_DIR="${ARCHIVE_DIR:-/tmp/xcode-archives}"

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

get_scheme_name() {
    local project_path="$1"
    local scheme="$2"

    if [ -n "$scheme" ]; then
        echo "$scheme"
        return
    fi

    local workspace=$(find "$project_path" -maxdepth 1 -name "*.xcworkspace" | head -1)
    local project=$(find "$project_path" -maxdepth 1 -name "*.xcodeproj" | head -1)

    if [ -n "$workspace" ]; then
        xcodebuild -list -workspace "$workspace" 2>/dev/null | grep -A 1 "Schemes:" | tail -1 | xargs
    elif [ -n "$project" ]; then
        xcodebuild -list -project "$project" 2>/dev/null | grep -A 1 "Schemes:" | tail -1 | xargs
    else
        error_exit "xcodeproj または xcworkspace が見つかりません"
    fi
}

validate_api_key() {
    if [ -z "$API_KEY_ID" ]; then
        error_exit "API_KEY_ID が設定されていません。$CONFIG_FILE を確認してください"
    fi
    if [ -z "$API_ISSUER_ID" ]; then
        error_exit "API_ISSUER_ID が設定されていません。$CONFIG_FILE を確認してください"
    fi
    if [ ! -f "$API_KEY_PATH" ]; then
        error_exit "API Key ファイルが見つかりません: $API_KEY_PATH"
    fi
}

archive_app() {
    local project_path="$1"
    local scheme="$2"
    local archive_path="$3"

    progress_msg "アーカイブ中: $scheme (Release)"

    local workspace=$(find "$project_path" -maxdepth 1 -name "*.xcworkspace" | head -1)
    local project=$(find "$project_path" -maxdepth 1 -name "*.xcodeproj" | head -1)

    local build_cmd="xcodebuild archive"
    if [ -n "$workspace" ]; then
        build_cmd="$build_cmd -workspace \"$workspace\""
    elif [ -n "$project" ]; then
        build_cmd="$build_cmd -project \"$project\""
    else
        error_exit "プロジェクトファイルが見つかりません"
    fi

    build_cmd="$build_cmd -scheme \"$scheme\""
    build_cmd="$build_cmd -configuration Release"
    build_cmd="$build_cmd -archivePath \"$archive_path\""
    build_cmd="$build_cmd -destination 'generic/platform=iOS'"
    build_cmd="$build_cmd -allowProvisioningUpdates"
    build_cmd="$build_cmd -authenticationKeyPath \"$API_KEY_PATH\""
    build_cmd="$build_cmd -authenticationKeyID \"$API_KEY_ID\""
    build_cmd="$build_cmd -authenticationKeyIssuerID \"$API_ISSUER_ID\""

    if eval "$build_cmd" > /tmp/xcodebuild_archive.log 2>&1; then
        success_msg "アーカイブ成功: $archive_path"
        return 0
    else
        echo "ERROR: アーカイブ失敗。ログの最後の${BUILD_LOG_LINES:-30}行:"
        tail -n "${BUILD_LOG_LINES:-30}" /tmp/xcodebuild_archive.log
        return 1
    fi
}

export_and_upload() {
    local archive_path="$1"
    local export_path="$2"

    progress_msg "App Store Connect にエクスポート＆アップロード中"

    local export_cmd="xcodebuild -exportArchive"
    export_cmd="$export_cmd -archivePath \"$archive_path\""
    export_cmd="$export_cmd -exportOptionsPlist \"$EXPORT_OPTIONS_PLIST\""
    export_cmd="$export_cmd -exportPath \"$export_path\""
    export_cmd="$export_cmd -allowProvisioningUpdates"
    export_cmd="$export_cmd -authenticationKeyPath \"$API_KEY_PATH\""
    export_cmd="$export_cmd -authenticationKeyID \"$API_KEY_ID\""
    export_cmd="$export_cmd -authenticationKeyIssuerID \"$API_ISSUER_ID\""

    if eval "$export_cmd" > /tmp/xcodebuild_export.log 2>&1; then
        success_msg "App Store Connect へのアップロード成功"
        return 0
    else
        echo "ERROR: エクスポート/アップロード失敗。ログの最後の${BUILD_LOG_LINES:-30}行:"
        tail -n "${BUILD_LOG_LINES:-30}" /tmp/xcodebuild_export.log
        return 1
    fi
}

# ==================== メイン処理 ====================

main() {
    echo ""
    echo "========================================="
    echo "  App Store Connect Upload"
    echo "========================================="
    echo ""

    cd "$PROJECT_PATH" || error_exit "プロジェクトパスが見つかりません: $PROJECT_PATH"

    validate_api_key
    success_msg "API Key 検証OK (Key ID: $API_KEY_ID)"

    if [ -z "$SCHEME" ]; then
        progress_msg "スキーム自動検出"
        SCHEME=$(get_scheme_name "$PROJECT_PATH" "$SCHEME")
        success_msg "スキーム: $SCHEME"
    else
        echo "スキーム: $SCHEME"
    fi

    local timestamp=$(date +%Y%m%d_%H%M%S)
    mkdir -p "$ARCHIVE_DIR"
    local archive_path="$ARCHIVE_DIR/${SCHEME}_${timestamp}.xcarchive"
    local export_path="$ARCHIVE_DIR/export_${timestamp}"

    echo ""
    echo "-----------------------------------------"
    echo "  Step 1/2: Archive"
    echo "-----------------------------------------"

    if ! archive_app "$PROJECT_PATH" "$SCHEME" "$archive_path"; then
        error_exit "アーカイブに失敗しました"
    fi

    echo ""
    echo "-----------------------------------------"
    echo "  Step 2/2: Export & Upload"
    echo "-----------------------------------------"

    if ! export_and_upload "$archive_path" "$export_path"; then
        error_exit "エクスポート/アップロードに失敗しました"
    fi

    echo ""
    echo "-----------------------------------------"
    echo "  クリーンアップ"
    echo "-----------------------------------------"
    rm -rf "$archive_path"
    rm -rf "$export_path"
    success_msg "一時ファイルを削除しました"

    echo ""
    echo "========================================="
    echo "  完了! App Store Connect にアップロードされました"
    echo "========================================="
    echo ""
    echo "TestFlight または App Store Connect で確認してください:"
    echo "  https://appstoreconnect.apple.com"
    echo ""
}

main "$@"
