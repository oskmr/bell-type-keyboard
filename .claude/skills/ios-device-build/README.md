# iOS Device Build Skill

Swift/iOSアプリを実機にビルド・インストール・起動する自動化スキル。

## 特徴

- 🚀 **高速**: インクリメンタルビルドで約30秒
- 🔄 **自動化**: xcodebuild → devicectl install → devicectl launch
- 🎯 **汎用的**: どのSwift/iOSプロジェクトでも動作
- ⚙️ **カスタマイズ可能**: デバイス、スキームを設定可能

## インストール

Calme リポジトリに同梱されています。clone 後、必要に応じて個人設定を行ってください。

```bash
# 個人のデバイス名（任意）
cp .cursor/skills/ios-device-build/config/settings.local.conf.example \
   .cursor/skills/ios-device-build/config/settings.local.conf

# スクリプトに実行権限を付与（必要な場合）
chmod +x .cursor/skills/ios-device-build/scripts/device_build.sh
```

## 初回セットアップ

```bash
# 個人のデバイス名を設定（任意）
cp .cursor/skills/ios-device-build/config/settings.local.conf.example \
   .cursor/skills/ios-device-build/config/settings.local.conf
nano .cursor/skills/ios-device-build/config/settings.local.conf
```

プロジェクト共通設定（スキーム・バンドル ID）は `config/settings.conf` に設定済みです。

## 使い方

```bash
# プロジェクトディレクトリで実行
cd /path/to/your/ios/project
bash .cursor/skills/ios-device-build/scripts/device_build.sh

# またはエイリアスを作成
echo 'alias ios-build="bash .cursor/skills/ios-device-build/scripts/device_build.sh"' >> ~/.zshrc
source ~/.zshrc

# これだけでOK！
ios-build
```

詳細は [SKILL.md](SKILL.md) を参照してください。

## 前提条件

- Xcode
- 有効な開発者証明書
- デバイスがMacに接続されている

## ライセンス

MIT
