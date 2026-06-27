#!/bin/bash

# iOS Device Build Script
# xcodebuild → devicectl install → devicectl launch の自動化

set -e

# Cursor等でDEVELOPER_DIRが未設定の場合にXcodeツールを検出できるようにする
if [ -z "${DEVELOPER_DIR:-}" ]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

# ==================== 設定読み込み ====================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$SKILL_DIR/config/settings.conf"
LOCAL_CONFIG_FILE="$SKILL_DIR/config/settings.local.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
if [ -f "$LOCAL_CONFIG_FILE" ]; then
    source "$LOCAL_CONFIG_FILE"
fi

# ==================== パラメータ ====================
PROJECT_PATH="${1:-.}"
SCHEME="${2:-$DEFAULT_SCHEME}"
DEVICE_NAME="${3:-$DEFAULT_DEVICE_NAME}"
BUNDLE_ID="${4:-}"
CLEAN_BUILD="${5:-no}"  # yes/no でクリーンビルドを制御

# ==================== 関数定義 ====================

# エラーメッセージ出力
error_exit() {
    echo "❌ エラー: $1" >&2
    exit 1
}

# 成功メッセージ出力
success_msg() {
    if [ "$NOTIFY_LANGUAGE" = "ja" ]; then
        echo "✅ $1"
    else
        echo "✅ $1"
    fi
}

# プログレス表示
progress_msg() {
    echo "🔄 $1..."
}

# デバイスUDID取得（xcodebuild用）
get_device_udid() {
    local device_name="$1"
    local device_info
    
    if [ -z "$device_name" ]; then
        # 自動検出：接続中の最初のiOSデバイス（Mac / Simulator は除外）
        device_info=$(xcrun xctrace list devices 2>/dev/null | grep "(" | grep -v "Simulator" | grep -vi "Mac" | grep -v "Offline" | head -1)
    else
        # 名前で検索（> などを正規表現にしない）
        device_info=$(xcrun xctrace list devices 2>/dev/null | grep -F "$device_name" | grep -v "Offline" | head -1)
    fi
    
    if [ -z "$device_info" ]; then
        error_exit "デバイスが見つかりません。デバイス名: $device_name"
    fi
    
    # UDIDを抽出（括弧内の最後の文字列、形式: 00008120-001954A43C90C01E）
    echo "$device_info" | grep -oE '\([0-9A-Fa-f]{8}-[0-9A-Fa-f]+\)' | tail -1 | tr -d '()'
}

# デバイスIdentifier取得（devicectl用）
# ※ State が connecting / preparing の間は devicectl install できないため、
#    DEVICECTL_WAIT_SECS（既定180）秒まで待ってから再試行する。
get_device_identifier() {
    local device_name="$1"
    local device_info
    local max_wait="${DEVICECTL_WAIT_SECS:-180}"
    local interval=5
    local elapsed=0
    local status_line

    _devicectl_pick_ready_line() {
        if [ -z "$device_name" ]; then
            xcrun devicectl list devices 2>/dev/null | grep -E "available|connected" | head -1
        else
            xcrun devicectl list devices 2>/dev/null | grep -F "$device_name" | grep -E "available|connected" | head -1
        fi
    }

    _devicectl_status_line() {
        if [ -z "$device_name" ]; then
            xcrun devicectl list devices 2>/dev/null | grep -E "available|connected|connecting|preparing" | head -1
        else
            xcrun devicectl list devices 2>/dev/null | grep -F "$device_name" | head -1
        fi
    }

    device_info=$(_devicectl_pick_ready_line)
    if [ -n "$device_info" ]; then
        echo "$device_info" | awk '{print $3}'
        return 0
    fi

    # connecting / preparing なら待機（実機が USB でも Core Device の確立に時間がかかる）
    status_line=$(_devicectl_status_line)
    if [ -n "$device_name" ] && [ -n "$status_line" ] && echo "$status_line" | grep -qiE "connecting|preparing"; then
        progress_msg "devicectl: 接続確立待ち（最大 ${max_wait}s）…"
        echo "   現在: $status_line"
        while [ "$elapsed" -lt "$max_wait" ]; do
            sleep "$interval"
            elapsed=$((elapsed + interval))
            device_info=$(_devicectl_pick_ready_line)
            if [ -n "$device_info" ]; then
                success_msg "devicectl接続確立（約 ${elapsed}s）"
                echo "$device_info" | awk '{print $3}'
                return 0
            fi
            status_line=$(_devicectl_status_line)
            echo "   … ${elapsed}s / ${max_wait}s  $status_line"
        done
    fi

    error_exit "devicectl用のデバイスが見つかりません。デバイス名: ${device_name:-（自動）} — Xcode の Devices で connected になるか、USB・データケーブル・「ネットワーク経由で接続」オフを確認。長い場合は DEVICECTL_WAIT_SECS=300 などで再実行。"
}

# スキーム名取得
get_scheme_name() {
    local project_path="$1"
    local scheme="$2"
    
    if [ -n "$scheme" ]; then
        echo "$scheme"
        return
    fi
    
    # workspace があれば優先
    local workspace=$(find "$project_path" -maxdepth 1 -name "*.xcworkspace" | head -1)
    local project=$(find "$project_path" -maxdepth 1 -name "*.xcodeproj" | head -1)
    
    local list_output=""
    local preferred_name=""
    
    if [ -n "$workspace" ]; then
        preferred_name=$(basename "$workspace" .xcworkspace)
        list_output=$(xcodebuild -list -workspace "$workspace" 2>/dev/null)
    elif [ -n "$project" ]; then
        preferred_name=$(basename "$project" .xcodeproj)
        list_output=$(xcodebuild -list -project "$project" 2>/dev/null)
    else
        error_exit "xcodeproj または xcworkspace が見つかりません"
    fi
    
    # Schemes: 以降の行からスキーム一覧を取得
    local schemes
    schemes=$(echo "$list_output" | awk '/Schemes:/{flag=1; next} /^[^[:space:]]/{if(flag) exit} flag && NF{print}' | sed 's/^[[:space:]]*//')
    
    # 1. プロジェクト名と一致するスキームを優先（Cal AI.xcodeproj → Cal AI）
    if [ -n "$preferred_name" ]; then
        local matched
        matched=$(echo "$schemes" | grep -Fx "$preferred_name" | head -1)
        if [ -n "$matched" ]; then
            echo "$matched"
            return
        fi
    fi
    
    # 2. フォールバック: 先頭のスキーム
    echo "$schemes" | head -1 | xargs
}

# バンドルID取得
get_bundle_id() {
    local project_path="$1"
    local scheme="$2"
    local bundle_id="$3"
    
    if [ -n "$bundle_id" ]; then
        echo "$bundle_id"
        return
    fi
    
    # Info.plist から取得
    local info_plist=$(find "$project_path" -name "Info.plist" -o -name "*-Info.plist" | head -1)
    if [ -n "$info_plist" ]; then
        /usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$info_plist" 2>/dev/null || echo ""
    fi
}

# ビルド
build_app() {
    local project_path="$1"
    local scheme="$2"
    local device_udid="$3"
    local clean="$4"
    
    if [ "$clean" = "yes" ]; then
        progress_msg "クリーンビルド中: $scheme"
    else
        progress_msg "ビルド中（インクリメンタル）: $scheme"
    fi
    
    local workspace=$(find "$project_path" -maxdepth 1 -name "*.xcworkspace" | head -1)
    local project=$(find "$project_path" -maxdepth 1 -name "*.xcodeproj" | head -1)
    
    local clean_flag=""
    if [ "$clean" = "yes" ]; then
        clean_flag="clean"
    fi
    
    local build_cmd=""
    if [ -n "$workspace" ]; then
        build_cmd="xcodebuild -workspace \"$workspace\" -scheme \"$scheme\" -configuration Debug -destination 'id=$device_udid' -allowProvisioningUpdates $clean_flag build"
    elif [ -n "$project" ]; then
        build_cmd="xcodebuild -project \"$project\" -scheme \"$scheme\" -configuration Debug -destination 'id=$device_udid' -allowProvisioningUpdates $clean_flag build"
    else
        error_exit "プロジェクトファイルが見つかりません"
    fi
    
    # ビルド実行
    if eval "$build_cmd" > /tmp/xcodebuild.log 2>&1; then
        success_msg "ビルド成功"
        return 0
    else
        echo "❌ ビルド失敗。ログの最後の${BUILD_LOG_LINES:-30}行:"
        tail -n "${BUILD_LOG_LINES:-30}" /tmp/xcodebuild.log
        return 1
    fi
}

# アプリパス取得（最新のものを取得）
get_app_path() {
    local scheme="$1"
    
    # DerivedData から .app を検索（Index.noindexを除外し、最新のものを取得）
    local app_path=$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -path "*/Build/Products/Debug-iphoneos/*" -type d 2>/dev/null | grep -v "Index.noindex" | while read f; do echo "$(stat -f '%m' "$f") $f"; done | sort -rn | head -1 | cut -d' ' -f2-)
    
    if [ -z "$app_path" ]; then
        error_exit "ビルドされた .app が見つかりません: ${scheme}.app"
    fi
    
    echo "$app_path"
}

# インストール
install_app() {
    local device_identifier="$1"
    local app_path="$2"
    
    progress_msg "インストール中: $(basename "$app_path")"
    
    if xcrun devicectl device install app --device "$device_identifier" "$app_path" 2>&1; then
        success_msg "インストール成功"
        return 0
    else
        error_exit "インストール失敗"
    fi
}

# 起動
launch_app() {
    local device_identifier="$1"
    local bundle_id="$2"
    
    if [ -z "$bundle_id" ]; then
        echo "⚠️  バンドルIDが不明のため、アプリの自動起動をスキップします"
        return 0
    fi
    
    progress_msg "起動中: $bundle_id"
    
    if xcrun devicectl device process launch --device "$device_identifier" "$bundle_id" 2>&1; then
        success_msg "起動成功"
        return 0
    else
        echo "⚠️  起動失敗（手動で起動してください）"
        return 0
    fi
}

# ==================== メイン処理 ====================

main() {
    echo ""
    echo "========================================="
    echo "  iOS Device Build & Launch"
    echo "========================================="
    echo ""
    
    # プロジェクトパスへ移動
    cd "$PROJECT_PATH" || error_exit "プロジェクトパスが見つかりません: $PROJECT_PATH"
    
    # デバイスUDID取得（xcodebuild用）
    progress_msg "デバイス検索: $DEVICE_NAME"
    DEVICE_UDID=$(get_device_udid "$DEVICE_NAME")
    success_msg "ビルド用デバイスUDID: $DEVICE_UDID"
    
    # デバイスIdentifier取得（devicectl用）
    DEVICE_IDENTIFIER=$(get_device_identifier "$DEVICE_NAME")
    success_msg "インストール用デバイスID: $DEVICE_IDENTIFIER"
    
    # スキーム名取得
    if [ -z "$SCHEME" ]; then
        progress_msg "スキーム自動検出"
        SCHEME=$(get_scheme_name "$PROJECT_PATH" "$SCHEME")
        success_msg "スキーム検出: $SCHEME"
    else
        echo "📋 スキーム: $SCHEME"
    fi
    
    # バンドルID取得
    if [ -z "$BUNDLE_ID" ]; then
        BUNDLE_ID=$(get_bundle_id "$PROJECT_PATH" "$SCHEME" "$BUNDLE_ID")
        if [ -z "$BUNDLE_ID" ] && [ -n "${DEFAULT_BUNDLE_ID:-}" ]; then
            BUNDLE_ID="$DEFAULT_BUNDLE_ID"
            echo "📦 バンドルID（設定使用）: $BUNDLE_ID"
        elif [ -n "$BUNDLE_ID" ]; then
            success_msg "バンドルID検出: $BUNDLE_ID"
        else
            echo "⚠️  バンドルIDを自動取得できませんでした"
        fi
    else
        echo "📦 バンドルID: $BUNDLE_ID"
    fi
    
    echo ""
    
    # ビルド
    if ! build_app "$PROJECT_PATH" "$SCHEME" "$DEVICE_UDID" "$CLEAN_BUILD"; then
        error_exit "ビルドに失敗しました"
    fi
    
    # アプリパス取得
    APP_PATH=$(get_app_path "$SCHEME")
    echo "📱 アプリパス: $APP_PATH"
    echo ""
    
    # インストール
    if ! install_app "$DEVICE_IDENTIFIER" "$APP_PATH"; then
        error_exit "インストールに失敗しました"
    fi
    
    echo ""
    
    # 起動
    launch_app "$DEVICE_IDENTIFIER" "$BUNDLE_ID"
    
    echo ""
    echo "========================================="
    echo "  🎉 完了！"
    echo "========================================="
    echo ""
}

# 実行
main "$@"
