---
name: ios-appstore-upload
description: iOSアプリをApp Store Connectにアーカイブ＆アップロードする。使用タイミング:(1)「App Storeにアップロードして」(2)「TestFlightにアップして」(3)「アップロードして」(4)「ストアに提出して」(5)「リリースして」などApp Store Connect提出が必要な時。xcodebuild archive → exportArchive (upload) の一連のフローを自動化。
---

# iOS App Store Upload

iOSアプリのアーカイブとApp Store Connectへのアップロードを自動化するスキル。

## 使用方法

### 基本的な使い方

```bash
bash .cursor/skills/ios-appstore-upload/scripts/appstore_upload.sh
```

カレントディレクトリのプロジェクトをアーカイブし、App Store Connectにアップロードします。

### パラメータ指定

```bash
bash .cursor/skills/ios-appstore-upload/scripts/appstore_upload.sh <project_path> [scheme]
```

| パラメータ | 説明 | デフォルト |
|-----------|------|----------|
| `project_path` | プロジェクトのパス | `.`（カレントディレクトリ） |
| `scheme` | ビルドスキーム | 設定ファイル → xcodeproj名から自動検出 |

### 実行フロー

1. **API Key検証**: 設定ファイルからApp Store Connect APIキー情報を読み込み・検証
2. **スキーム検出**: xcodeproj/xcworkspace から自動検出
3. **アーカイブ**: `xcodebuild archive` でRelease構成の .xcarchive を作成
4. **エクスポート＆アップロード**: `xcodebuild -exportArchive` でIPAを書き出し、App Store Connectに直接アップロード
5. **クリーンアップ**: 一時ファイルを削除

## 設定ファイル

### 場所

`.cursor/skills/ios-appstore-upload/config/settings.conf`

### 形式

```bash
# App Store Connect API Key 設定
API_KEY_ID="YOUR_KEY_ID"
API_ISSUER_ID="YOUR_ISSUER_ID"
API_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_YOUR_KEY_ID.p8"

# デフォルトのスキーム名（空欄で自動検出）
DEFAULT_SCHEME=""

# アーカイブ出力先
ARCHIVE_DIR="/tmp/xcode-archives"

# ビルドログの表示行数
BUILD_LOG_LINES=30
```

## ExportOptions.plist

`.cursor/skills/ios-appstore-upload/ExportOptions.plist`

App Store Connect向けの設定済み。自動署名、シンボルアップロード、バージョン自動管理が有効。

## 前提条件

- Xcode がインストール済み
- 有効なApple Developer Program メンバーシップ
- App Store Distribution用の証明書（自動署名で管理可能）
- App Store Connect API Key（.p8ファイル）が `~/.appstoreconnect/private_keys/` に配置済み
- App Store Connectでアプリが作成済み

## ビルドログ

| ログ | パス |
|------|------|
| アーカイブログ | `/tmp/xcodebuild_archive.log` |
| エクスポートログ | `/tmp/xcodebuild_export.log` |

## トラブルシューティング

| エラー | 解決策 |
|--------|--------|
| API Key検証失敗 | settings.confのAPI_KEY_ID、API_ISSUER_ID、API_KEY_PATHを確認 |
| アーカイブ失敗 | 証明書/プロビジョニングプロファイルを確認。`cat /tmp/xcodebuild_archive.log` でログ確認 |
| アップロード失敗 | App Store Connectでアプリが作成済みか確認。バージョン/ビルド番号の重複がないか確認 |
| 署名エラー | Xcodeで配布用証明書が有効か確認 |

## ファイル構成

```
.cursor/skills/ios-appstore-upload/
├── SKILL.md
├── config/
│   └── settings.conf
├── scripts/
│   └── appstore_upload.sh
└── ExportOptions.plist
```
