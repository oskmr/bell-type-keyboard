---
name: ios-device-build
description: Swift/iOSアプリを実機にビルド・インストール・起動する。使用タイミング:(1)「実機にビルドして」(2)「iPhoneで動かして」(3)「デバイスにインストールして」(4)「実機で確認して」(5)「実機デプロイ」など実機デバッグが必要な時。xcodebuild → devicectl install → devicectl launchの一連のフローを自動化。
---

# iOS Device Build

iOS実機へのビルド・インストール・起動を自動化するスキル。

## 使用方法

### 基本的な使い方

```bash
bash .cursor/skills/ios-device-build/scripts/device_build.sh
```

現在のディレクトリのプロジェクトを、デフォルトデバイスにビルド・インストール・起動します。

### パラメータ指定

```bash
bash .cursor/skills/ios-device-build/scripts/device_build.sh <project_path> [scheme] [device_name] [bundle_id]
```

| パラメータ | 説明 | デフォルト |
|-----------|------|----------|
| `project_path` | プロジェクトのパス | `.`（カレントディレクトリ） |
| `scheme` | ビルドスキーム | 設定ファイル → xcodeproj名から自動検出 |
| `device_name` | デバイス名 | 設定ファイル → 接続中の最初のデバイス |
| `bundle_id` | バンドルID | Info.plistから自動取得 |

**優先順位**: コマンド引数 > 設定ファイル > 自動検出

### 実行フロー

1. **設定確認**: `.cursor/skills/ios-device-build/config/settings.conf` を読み込み
2. **デバイス検出**: `xcrun devicectl list devices` でデバイスのUDIDを取得
3. **スキーム検出**: xcodeproj/xcworkspace から自動検出
4. **バンドルID取得**: Info.plist から取得
5. **ビルド**: `xcodebuild` でデバイス向けにコンパイル
6. **インストール**: `xcrun devicectl device install app` でデバイスにインストール
7. **起動**: `xcrun devicectl device process launch` でアプリを起動

## 設定ファイル

### 場所

- `.cursor/skills/ios-device-build/config/settings.conf` — プロジェクト共通（スキーム・バンドル ID）
- `.cursor/skills/ios-device-build/config/settings.local.conf` — 個人設定（デバイス名、gitignore 対象）

### 形式

```bash
# デフォルトのデバイス名（部分一致で検索）
# 空欄の場合は毎回自動検出
DEFAULT_DEVICE_NAME=""

# デフォルトのスキーム名（空欄で自動検出）
DEFAULT_SCHEME=""

# 完了通知の言語（"ja" or "en"）
NOTIFY_LANGUAGE="ja"

# ビルドログの表示行数
BUILD_LOG_LINES=30
```

### 設定の変更

```bash
# 現在の設定を確認
cat .cursor/skills/ios-device-build/config/settings.conf

# エディタで編集
nano .cursor/skills/ios-device-build/config/settings.conf
```

## 手動実行コマンド（参考）

### 接続デバイス一覧
```bash
xcrun devicectl list devices
```

### ビルド
```bash
xcodebuild \
  -workspace "Project.xcworkspace" \
  -scheme "MyScheme" \
  -configuration Debug \
  -destination 'id=<UDID>' \
  -allowProvisioningUpdates \
  clean build
```

### インストール
```bash
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "MyScheme.app" -path "*/Debug-iphoneos/*" -type d | head -1)
xcrun devicectl device install app --device <UDID> "$APP_PATH"
```

### 起動
```bash
xcrun devicectl device process launch --device <UDID> <bundle_id>
```

## 前提条件

- Xcode がインストール済み
- 有効な開発者証明書とプロビジョニングプロファイル
- デバイスがMac に接続され、信頼済みであること
- デバイスのロックが解除されていること

## トラブルシューティング

| エラー | 解決策 |
|--------|--------|
| No devices found | デバイスが接続・ロック解除されているか確認 |
| Device not found | デバイス名を確認、または設定をリセット |
| Build failed | Xcodeでエラー詳細確認、証明書/プロビジョニング確認 |
| Install failed | 「設定 > 一般 > VPNとデバイス管理」で開発元を信頼 |
| Launch failed | バンドルIDが正しいか確認 |

### ビルドエラーの確認

ビルドログは `/tmp/xcodebuild.log` に保存されます：

```bash
cat /tmp/xcodebuild.log
```

## ファイル構成

```
.cursor/skills/ios-device-build/
├── SKILL.md
├── config/
│   ├── settings.conf                 # プロジェクト共通設定
│   ├── settings.local.conf.example   # 個人設定テンプレート
│   └── settings.conf.example         # 設定例
└── scripts/
    └── device_build.sh
```

## 使用例

### 例1: カレントディレクトリのプロジェクトをビルド

```bash
cd /path/to/MyProject
bash .cursor/skills/ios-device-build/scripts/device_build.sh
```

### 例2: パスを指定してビルド

```bash
bash .cursor/skills/ios-device-build/scripts/device_build.sh ~/Documents/MyApp
```

### 例3: スキームとデバイスを明示的に指定

```bash
bash .cursor/skills/ios-device-build/scripts/device_build.sh . "MyScheme" "iPhone 14 Pro"
```

### 例4: すべてのパラメータを指定

```bash
bash .cursor/skills/ios-device-build/scripts/device_build.sh \
  ~/Documents/MyApp \
  "MyScheme" \
  "iPhone 14 Pro" \
  "com.example.myapp"
```

## 注意事項

- 初回実行時は証明書の許可が必要な場合があります
- デバイスが「信頼されていません」と表示される場合は、デバイスで「このコンピュータを信頼」を選択してください
- アプリ起動時にエラーが出る場合は、デバイスの設定で開発者証明書を信頼する必要があります
