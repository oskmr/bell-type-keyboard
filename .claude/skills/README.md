# Agent Skills

プロジェクトの Agent Skills を `.claude/skills/` で管理します。  
リポジトリを clone すれば、チーム全員が同じスキルを Claude が自動認識します。

## スキル一覧

| スキル | 用途 |
|--------|------|
| `bell-type-keyboard-ios-development` | bell-type-keyboard 固有のデザインシステム・コーディング規約 |
| `ios-device-build` | 実機ビルド・インストール・起動 |
| `ios-appstore-upload` | App Store Connect へのアーカイブ＆アップロード |
| `ios-appstore-submit` | 審査申請（バージョンバンプ〜提出） |
| `no-auto-build` / `no-auto-ios-build` | 明示指示以外のビルド禁止 |
| `simple-code-principles` | YAGNI / KISS / DRY |
| `swift-coding-standards` | Swift/SwiftUI コーディング規約 |
| `swiftui-pro` | SwiftUI ベストプラクティス |
| `git-pull-latest` | 「最新にして」→ git pull |
| `commit-pr` | 差分を整理してコミットし、PR を自動作成 |
| `harada-growth-principles` | グロース戦略の評価 |

## 初回セットアップ（新メンバー）

### 1. リポジトリを clone

Skills はリポジトリに含まれているため、追加作業は不要です。

### 2. 個人設定（任意）

デバイス名や App Store Connect API キーなど、個人・環境依存の設定のみローカルで行います。

```bash
# 実機ビルド: デバイス名を設定
cp .claude/skills/ios-device-build/config/settings.local.conf.example \
   .claude/skills/ios-device-build/config/settings.local.conf
# settings.local.conf を編集

# App Store アップロード: API キーを設定
cp .claude/skills/ios-appstore-upload/config/settings.conf.example \
   .claude/skills/ios-appstore-upload/config/settings.conf
# settings.conf を編集（.p8 キーは ~/.appstoreconnect/private_keys/ に配置）
```

### 3. スクリプトに実行権限（必要な場合）

```bash
chmod +x .claude/skills/ios-device-build/scripts/*.sh
chmod +x .claude/skills/ios-appstore-upload/scripts/*.sh
chmod +x .claude/skills/ios-appstore-submit/scripts/*.sh
```

## 個人スキル（~/.claude/skills）からの移行

以前は `~/.claude/skills/` にシンボリックリンクで個人管理していました。  
**プロジェクトの `.claude/skills/` を正** とします。

- Claude は `.claude/skills/<name>/SKILL.md` を自動読み込み
- 個人の `~/.claude/skills/` は削除または無効化して問題ありません

## スキルの追加・更新

1. `.claude/skills/<skill-name>/SKILL.md` を作成または編集
2. スクリプト付きスキルは `scripts/` 配下に配置し、パスはスクリプト相対（`$(dirname "$0")`）で解決
3. 個人設定は `settings.local.conf` 等に分離し `.gitignore` 対象にする

## 参考

- [Agent Skills 公式](https://agentskills.io/what-are-skills)
- [docs/AGENT_SKILLS_GUIDE.md](../../docs/AGENT_SKILLS_GUIDE.md)
