---
name: calme-ios-development
description: Cal AI (Calme) iOSアプリ開発時のデザインシステム、コーディング規約、アーキテクチャパターンを適用する
---

# Cal AI (Calme) 開発スキル

このスキルは、Cal AI (Calme) iOSアプリの開発時に、デザインの一貫性とコーディング品質を維持するためのガイドラインです。

## いつこのスキルを使うか

- 新しいSwiftUIビューを作成する時
- UI コンポーネントを設計・実装する時
- 既存の画面を修正・拡張する時
- デザインシステムに関する判断が必要な時
- コードレビュー時の品質確認

## デザインシステム

### カラーパレット

#### プライマリカラー
- **グリーン** (`Color.primaryAppColor = Color.green`): プライマリアクセント、選択状態、プログレスバー
- **オレンジ** (`Color.orange`): ポイントシステム、報酬、特別なアクション

#### グラデーション
```swift
Color.gradient1 = Color(hex: "#2A6FFA")
Color.gradient2 = Color(hex: "#6717CE")
LinearGradient(colors: [Color.gradient1, Color.gradient2], startPoint: .leading, endPoint: .trailing)
```
- サブスクリプション関連のボタンやCTAに使用

#### システムカラー（推奨）
- `.primary`: メインテキスト
- `.secondary`: 補足情報・説明文
- `.systemGray3`, `.systemGray4`, `.systemGray5`, `.systemGray6`: 背景・ボーダー
- `.systemBackground`: メイン背景
- カスタムカラー最小限: `gray7 = Color(hex: "#F6F6F9")`

#### セマンティックカラー
- 緑: 成功・進捗・健康
- 赤: オーバー・警告・削除
- 黒: プライマリテキスト
- グレー: セカンダリテキスト・背景

### レイアウトパターン

#### 角丸（cornerRadius）
- **12px**: 標準的なカード・画像・コンテナ
- **14px**: セクション・中サイズボタン
- **16px**: 大きなカード・モーダル
- **20px**: 大きなコンテナ・特別な要素（アイコンプレビューなど）
- **26px**: プライマリボタン（`PrimarySaveButton`）
- **30px**: プロフィール画像など

#### パディング・スペーシング
- **水平パディング**: 16px, 18px, 20px
- **垂直パディング**: 12px, 16px, 18px
- **要素間スペーシング**: 8px, 12px, 16px, 24px
- **セクション間**: 24px以上

#### レイアウト構造の基本
```swift
VStack(alignment: .leading, spacing: 24) {
    // セクション1
    // セクション2
}
.padding(.horizontal, 20)
.padding(.top, 20)
.padding(.bottom, 20)
```

### タイポグラフィ

#### フォントサイズ
- **28px (bold)**: 大見出し（画面タイトル）
- **20px (bold/semibold)**: 中見出し・重要な数値
- **18px (semibold)**: セクションタイトル
- **16px (body)**: 本文
- **14px (caption)**: 補足情報・説明文
- **12px**: 最小サイズ（曜日表示など）

#### フォントウェイト
```swift
.font(.system(size: 20, weight: .bold))      // 重要な情報・数値
.font(.system(size: 18, weight: .semibold))  // セクションタイトル・ボタン
.font(.system(size: 16, weight: .medium))    // 補助的な情報
.font(.body)                                  // 本文
```

### コンポーネント設計

#### 標準コンポーネント（再利用推奨）

1. **QuickActionRow**: 設定画面のリストアイテム
```swift
QuickActionRow(
    icon: "app.badge",
    title: "アプリアイコンを変更",
    iconColor: .primary,  // オプション
    titleColor: .primary  // オプション
)
.padding(.horizontal, 16)
.padding(.vertical, 18)
```

2. **PrimarySaveButton**: プライマリアクションボタン
```swift
PrimarySaveButton(
    title: "保存",
    isDisabled: false,
    backgroundColor: .primaryAppColor,
    foregroundColor: .white,
    systemIconName: "checkmark",  // オプション
    action: { /* action */ }
)
```

3. **RadioButtonOption**: 選択肢ボタン
```swift
RadioButtonOption(
    title: "オプション1",
    isSelected: selectedOption == 1,
    action: { selectedOption = 1 }
)
```

#### カード型コンテナ
```swift
VStack(spacing: 0) {
    // コンテンツ
}
.background(
    RoundedRectangle(cornerRadius: 14)
        .fill(Color(.systemBackground))
)
.overlay(
    RoundedRectangle(cornerRadius: 14)
        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
)
```

#### 情報バッジ（オレンジ残高など）
```swift
HStack {
    Image(systemName: "circle.fill")
        .foregroundColor(.orange)
        .font(.system(size: 16))
    Text("\(balance)")
        .font(.system(size: 20, weight: .bold))
        .foregroundColor(.primary)
    Spacer()
}
.padding(.horizontal, 20)
.padding(.vertical, 8)
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.orange.opacity(0.1))
)
```

### インタラクション

#### アニメーション
```swift
withAnimation(.easeInOut(duration: 0.2)) {
    // 標準的な遷移
}

withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    // 重要な状態変化
}
```

#### 触覚フィードバック
```swift
private func hapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)  // 軽い操作
    // または
    let generator = UIImpactFeedbackGenerator(style: .medium) // 標準的な操作
    generator.impactOccurred()
}
```

#### ボタンスタイル
- プレーンボタン: `.buttonStyle(.plain)` で標準の青色ハイライトを無効化
- カスタムタップ領域: `.contentShape(RoundedRectangle(cornerRadius: 26))`

## コーディング規約

### ファイルヘッダー
```swift
//
//  FileName.swift
//  Cal AI
//
//  Created by [Author] on [Date].
//
//  MARK: - [日本語での説明]
//  このファイルは[機能説明]です。
//  - [主要機能1]
//  - [主要機能2]
//
```

### MARK の使用
```swift
// MARK: - セクション名（大見出し）
// MARK: セクション名（小見出し）
```

### State管理
```swift
// UI状態
@State private var showAlert: Bool = false
@State private var selectedItem: Item?

// グローバル状態（ObservableObject）
@ObservedObject private var manager = Manager.shared

// 環境値
@Environment(\.dismiss) private var dismiss
```

### 命名規則
- **Bool**: `show`, `is`, `has` プレフィックス（例: `showAlert`, `isLoading`, `hasError`）
- **Action**: 動詞で始める（例: `handleIconTap`, `loadCurrentIcon`, `changeAppIcon`）
- **Private関数**: `private func` を優先

### エラーハンドリング
```swift
@State private var showAlert: Bool = false
@State private var alertMessage: String = ""

// エラー時
alertMessage = "エラーメッセージ"
showAlert = true

// Alert表示
.alert("エラー", isPresented: $showAlert) {
    Button("OK", role: .cancel) {}
} message: {
    Text(alertMessage)
}
```

### 非同期処理
```swift
Task {
    await someAsyncFunction()
}

// または
Task { @MainActor in
    // UIに関する処理
}
```

## アーキテクチャパターン

### ViewModel パターン（必要に応じて）
- 複雑な状態管理が必要な場合のみ
- `ObservableObject` を使用
- `@Published` でUI更新

### Manager パターン（グローバル状態）
```swift
class SomeManager: ObservableObject {
    static let shared = SomeManager()
    
    @Published var someState: SomeType = defaultValue
    
    private init() {}
    
    func someAction() async {
        // 処理
    }
}

// 使用
@ObservedObject private var manager = SomeManager.shared
```

### データ永続化
- `UserDefaults`: 簡易的な設定・フラグ
- `IntakeStore`: 食事記録（日付ベース）
- `Supabase`: クラウド同期

## UI実装チェックリスト

新しいビューを作成する時は以下を確認:

- [ ] ファイルヘッダーとMARKコメントを追加
- [ ] 角丸の値は標準値（12, 14, 16, 20, 26, 30）を使用
- [ ] パディング・スペーシングは標準値（8, 12, 16, 18, 20, 24）を使用
- [ ] フォントサイズは標準値を使用
- [ ] プライマリカラーは `Color.primaryAppColor` を使用
- [ ] ボタンに触覚フィードバックを追加
- [ ] アニメーションは `easeInOut` または `spring` を使用
- [ ] エラーハンドリングを実装（alert または toast）
- [ ] 既存コンポーネント（QuickActionRow, PrimarySaveButton等）を再利用
- [ ] システムカラーを優先的に使用（ダークモード対応）
- [ ] Preview を追加

## 既存コードの修正時の注意

- デザインシステムから外れている既存コードを見つけた場合、積極的に修正を提案
- ただし、動作中の機能を壊さないように慎重に
- 大きな変更の前にユーザーに確認を取る

## 参考ファイル

デザインやパターンに迷った時は以下のファイルを参照:

- `Cal AI/Home/AppIconSettingsView.swift`: 最新のデザインパターン例
- `Cal AI/Home/SettingsView.swift`: 設定画面の標準レイアウト
- `Cal AI/Extensions/Color.swift`: カラーシステム定義
- `Cal AI/Extensions/ButtonComponents.swift`: 再利用可能なボタン
- `DESIGN_ANALYSIS.md`: デザインシステムの詳細な分析

## 追加の開発ガイドライン

### 画像表示
```swift
if let previewImage = UIImage(named: imageName) {
    Image(uiImage: previewImage)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
} else {
    // フォールバック
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 80, height: 80)
}
```

### ローディング状態
```swift
if isLoading {
    Color.black.opacity(0.3)
        .ignoresSafeArea()
    ProgressView()
        .scaleEffect(1.5)
        .tint(.orange)  // または .primaryAppColor
}
```

### セクション区切り
```swift
Divider()
    .padding(.leading, 48)  // アイコン幅分左にオフセット
```

## まとめ

Cal AI (Calme) は **ミニマリズムとユーザビリティを重視** した、**一貫性のある** デザインシステムを持っています。

新しい機能を追加する際は:
1. 既存のコンポーネントを最大限再利用
2. デザイントークン（色・サイズ・スペーシング）を守る
3. 触覚フィードバックを忘れずに
4. ダークモード対応（システムカラー使用）を考慮
5. シンプルで直感的なUXを維持

このガイドラインに従うことで、アプリ全体の品質と一貫性が保たれます。

---

## 実機ビルド・デプロイ

実機にアプリをビルド・インストール・起動する場合は、プロジェクトスキル `ios-device-build` を使用してください。

### 使用タイミング
- 「実機にビルドして」
- 「iPhoneで動かして」  
- 「デバイスにインストールして」
- 「実機で確認して」
- 「実機デプロイ」

### 実行方法（Calme）
```bash
bash .cursor/skills/ios-device-build/scripts/device_build.sh
```

- **スキーム**: `Cal AI`（`settings.conf` に設定済み。自動検出すると `Amplitude-Swift` 等の SPM スキームを誤選択しやすい）
- **バンドルID**: `jp.co.labi.calme`（`settings.conf` に設定済み）
- **デバイス名**: 個人環境は `config/settings.local.conf` で設定

詳細は `.cursor/skills/ios-device-build/SKILL.md` を参照してください。
