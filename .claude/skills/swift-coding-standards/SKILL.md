---
name: swift-coding-standards
description: Swift/SwiftUIのコードスタイル・制約・プロジェクト規約。Swiftコードの作成・レビュー時に使用する。
---

# Swift Coding Standards

## Core Restrictions

- Force unwrapping (`!`) 禁止。
- `as!` 禁止。`as?` またはジェネリクスを使う。
- `try?` でのエラー握りつぶし禁止。`do-catch` で明示的にハンドリング。正当な理由がある場合のみ `try?` を許容し、コメントで理由を明記。
- GCD (`DispatchQueue`) 禁止 → Swift Concurrency (`async/await`)。
- Combine 禁止 → `@Observable`, `@State`, `@Environment`, `Task`。
- `NotificationCenter` / KVO 禁止 → DI や Observable Model パターン。
- `PreviewProvider` 禁止 → `#Preview` のみ。

## Swift Code Style

- `if let value {` 短縮構文を使う。
- 単一式では `return` を省略。`if`/`switch` を式として使う。
- `Double` を優先（`CGFloat` ではなく）。Optional/inout のみ `CGFloat` 許容。
- `Date.now` を使う（`Date()` ではなく）。
- `count(where:)` を使う（`filter().count` ではなく）。
- Swift-native 文字列メソッドを優先: `replacing("a", with: "b")`。
- モダンFoundation API: `URL.documentsDirectory`, `appending(path:)`。
- `String(format:)` 禁止 → `FormatStyle` API。
- `Task.sleep(for:)` を使う（`nanoseconds:` ではなく）。
- `Task.detached()` は原則禁止。
- `@AppStorage` に機密データ禁止 → Keychain。
- `let` を `var` より優先。
- 1ファイル1型。コンパイラ警告は全てエラー扱い。

## SwiftUI API

- `foregroundStyle()` (`foregroundColor()` 非推奨)
- `clipShape(.rect(cornerRadius:))` (`cornerRadius()` 非推奨)
- `NavigationStack` / `NavigationSplitView` (`NavigationView` 非推奨)
- `.topBarLeading/Trailing` (`.navigationBarLeading/Trailing` 非推奨)
- `navigationDestination(for:)` (`NavigationLink(destination:)` 非推奨)
- `onChange()` 2パラメータ or 0パラメータ版を使う
- `.scrollIndicators(.hidden)` (`showsIndicators: false` ではなく)
- `@Observable` クラスには `@MainActor`
- `ObservableObject`/`@Published`/`@StateObject`/`@ObservedObject`/`@EnvironmentObject` 原則不使用
- `Binding(get:set:)` を body 内で使わない → `onChange()`
- `Identifiable` 準拠を優先
- `AnyView` 禁止 → `@ViewBuilder`/Group/ジェネリクス
- `task()` を使う（`onAppear()` での非同期禁止）
- `GeometryReader` は `containerRelativeFrame()` 等で代替できる場合は使わない
- `onTapGesture()` より `Button`

## View Composition

- View分割はcomputed propertyではなく別のView structに抽出。
- ボタンアクションは別メソッドに。
- modifier切替は三項演算子（if/elseのView分岐ではなく）。
- View init は軽量に。重い処理は `task()`。
- body内にソート・フィルタを置かない。
- 大量データには `LazyVStack`/`LazyHStack`。
- `@State` は常に `private`。
- body/task()/onAppear()/ボタンクロージャにインラインロジックを書かない。

## Layout & Accessibility

- マージン・スペーシングは親が決定。子に含めない。
- 最小タップ領域 44x44。
- `UIScreen.main.bounds` 禁止。
- 固定フレーム回避。柔軟なレイアウト。
- Dynamic Type を尊重。固定フォントサイズ禁止。カスタムは `@ScaledMetric`。
- 画像ボタンにはテキストラベル必須。
- `bold()` を使う（`fontWeight(.bold)` ではなく）。
- `UIColor` 禁止 → SwiftUI `Color` / アセットカタログ。
- 空データは `ContentUnavailableView`。
- `ForEach` にユニークID。
