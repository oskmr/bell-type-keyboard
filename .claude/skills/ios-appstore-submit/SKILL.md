---
name: ios-appstore-submit
description: iOSアプリの審査申請を自動化する。バージョンバンプ、アーカイブ、アップロード、バージョン作成、リリースノート設定、審査提出までを一括実行。「審査出して」「審査申請して」「レビューに出して」「リリースして」等で起動。
---

# iOS App Store Review Submission

App Store Connectへの審査申請をワンコマンドで自動化するスキル。

## 使用タイミング

- 「審査出して」「審査申請して」
- 「レビューに出して」
- 「リリースして」
- 「App Storeに提出して」

## エージェントの実行手順

このスキルを使う場合、エージェントは以下の手順で実行すること：

### 1. リリースノートの準備

gitログから前回リリース以降の変更を分析し、リリースノートを生成する。

```bash
# 直近のタグからの変更を確認
git log $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~20)..HEAD --oneline
```

以下のテンプレートに従ってリリースノートを作成する：

```
いつも「Cal AI」をご利用いただきありがとうございます。
今回、以下のアップデートを実施しました!
・（ユーザー向けの変更点1）
・（ユーザー向けの変更点2）
```

**ルール:**
- ユーザーに見える変更のみ記載（内部リファクタリングは除外）
- 技術用語は避け、ユーザー目線で記述
- 「バグの修正」は具体的に書けない場合のみ使用

### 2. バージョン番号の決定

- ユーザーが指定した場合はそれを使用
- 指定がない場合は現在のバージョンのパッチを+1（例: 1.2 → 1.2.1、1.3.0 → 1.3.1）

### 3. スクリプト実行

```bash
bash .cursor/skills/ios-appstore-submit/scripts/submit_for_review.sh <project_path> <version> "<release_notes>"
```

| パラメータ | 説明 | 例 |
|-----------|------|-----|
| `project_path` | プロジェクトのパス | `.`（Calme リポジトリルート） |
| `version` | 新しいバージョン番号 | `1.3.1` |
| `release_notes` | リリースノート全文 | (上記テンプレート参照) |

### 実行フロー

1. **Version Bump** - project.pbxproj の MARKETING_VERSION を更新
2. **Archive & Upload** - ios-appstore-upload スキルを利用してアーカイブ＆アップロード
3. **Create Version** - App Store Connect APIで新バージョンを作成
4. **Set Release Notes** - リリースノートを設定（日本語）
5. **Submit for Review** - 審査に提出

## 前提条件

- ios-appstore-upload スキルが設定済み（API Key等）
- Python 3 + PyJWT + cryptography がインストール済み
- App Store Connectでアプリが作成済み

## 依存関係

- `ios-appstore-upload` スキル（アーカイブ＆アップロード処理）
- Python 3パッケージ: `PyJWT`, `cryptography`, `requests`

## トラブルシューティング

| エラー | 解決策 |
|--------|--------|
| JWT生成失敗 | `pip3 install PyJWT cryptography` を実行 |
| バージョン作成失敗 | 同一バージョンが既に存在しないか確認 |
| 審査提出失敗 | ビルドの処理完了を待ってから再試行。スクリーンショット等が揃っているか確認 |
| リリースノート設定失敗 | App Store Connectでアプリのローカライゼーション設定を確認 |

## ファイル構成

```
.cursor/skills/ios-appstore-submit/
├── SKILL.md
├── config/
│   └── settings.conf
└── scripts/
    ├── submit_for_review.sh
    └── appstore_api.py
```
