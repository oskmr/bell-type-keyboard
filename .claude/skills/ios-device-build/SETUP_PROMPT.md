# Cursor用セットアップ&実行プロンプト

別のPCでこのスキルを使う時に、CursorのAIエージェントに投げるプロンプトです。

---

## 📋 コピペ用プロンプト（日本語版）

```
iOS実機ビルドスキルをセットアップして、このプロジェクトを実機にビルド・インストール・起動してください。

リポジトリ: https://github.com/kuritataisuke/ios-device-build-skill.git

手順:
1. .cursor/skills/ios-device-build にクローン
2. config/settings.conf.example を config/settings.conf にコピー
3. 接続中のデバイス一覧を取得して、使用するデバイスを質問
4. settings.conf に選択したデバイス名を設定
5. このプロジェクトで実機ビルドを実行

スクリプトパス: .cursor/skills/ios-device-build/scripts/device_build.sh
```

---

## 📋 コピペ用プロンプト（英語版）

```
Set up the iOS device build skill and build, install, and launch this project on a physical device.

Repository: https://github.com/kuritataisuke/ios-device-build-skill.git

Steps:
1. Clone to .cursor/skills/ios-device-build
2. Copy config/settings.conf.example to config/settings.conf
3. List connected devices and ask me which one to use
4. Set the selected device name in settings.conf
5. Run device build for this project

Script path: .cursor/skills/ios-device-build/scripts/device_build.sh
```

---

## 📋 最短プロンプト（既にセットアップ済みの場合）

```
実機にビルドして
```

AIがスキルを検出して自動実行します。

---

## 💡 トラブルシューティング用プロンプト

### スキルが見つからない場合

```
.cursor/skills/ios-device-build が存在しないので、
https://github.com/kuritataisuke/ios-device-build-skill.git
からクローンしてセットアップしてください
```

### デバイスを変更したい場合

```
実機ビルドのデフォルトデバイスを変更したい。
現在接続されているデバイス一覧を表示して、新しいデバイスを選択させてください。
設定ファイル: .cursor/skills/ios-device-build/config/settings.conf
```

### クリーンビルドしたい場合

```
実機にクリーンビルドしてインストールして
```

---

## 🔧 手動セットアップ（AIを使わない場合）

```bash
# 1. クローン
mkdir -p ~/.claude/skills
git clone https://github.com/kuritataisuke/ios-device-build-skill.git .cursor/skills/ios-device-build

# 2. 設定ファイル作成
cp .cursor/skills/ios-device-build/config/settings.conf.example \
   .cursor/skills/ios-device-build/config/settings.conf

# 3. デバイス一覧確認
xcrun devicectl list devices

# 4. 設定編集（デバイス名を設定）
nano .cursor/skills/ios-device-build/config/settings.conf

# 5. 実行
cd /path/to/your/ios/project
bash .cursor/skills/ios-device-build/scripts/device_build.sh
```

---

## 📝 エイリアス設定（オプション）

AIに以下をお願いすると便利：

```
~/.zshrc に以下のエイリアスを追加してください:
alias ios-build="bash .cursor/skills/ios-device-build/scripts/device_build.sh"
```

これで `ios-build` だけで実機ビルドできるようになります。
