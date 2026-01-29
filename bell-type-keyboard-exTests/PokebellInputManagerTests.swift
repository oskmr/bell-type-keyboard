//
//  PokebellInputManagerTests.swift
//  bell-type-keyboard-exTests
//
//  Created by miseri.osaka on 2026/01/29.
//

import XCTest
@testable import bell_type_keyboard_ex

/// FakeConverter provides predictable candidates for unit tests.
///
/// Example:
/// ```swift
/// let converter = FakeConverter(candidate: "愛")
/// ```
final class FakeConverter: KanaKanjiConverting {
    private let candidate: String

    /// Initializes the fake converter with a fixed candidate.
    ///
    /// Example:
    /// ```swift
    /// let converter = FakeConverter(candidate: "愛")
    /// ```
    /// - Parameter candidate: The candidate to return for any input.
    init(candidate: String) {
        self.candidate = candidate
    }

    /// Returns a fixed candidate for any composing text.
    ///
    /// Example:
    /// ```swift
    /// let result = converter.convert(composingText: "あい")
    /// ```
    /// - Parameter composingText: The composing text.
    /// - Returns: A conversion result with the fixed candidate.
    func convert(composingText: String) -> KanaKanjiConversionResult {
        KanaKanjiConversionResult(
            composingText: composingText,
            candidateText: candidate,
            candidates: [candidate]
        )
    }
}

/// PokebellInputManagerTests validates composing and conversion behavior.
final class PokebellInputManagerTests: XCTestCase {
    /// Verifies that composing text keeps marked text as raw kana input.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))
    /// manager.pressKey(1)
    /// manager.pressKey(1)
    /// ```
    func testPressKeyUpdatesMarkedTextWithComposingText() {
        let converter = FakeConverter(candidate: "愛")
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: converter)

        var markedText: String?
        manager.onMarkedTextChange = { text in
            markedText = text
        }

        manager.pressKey(1)
        manager.pressKey(1)

        XCTAssertEqual(markedText, "あ")
    }

    /// Verifies that confirming input commits the candidate and clears composing state.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))
    /// manager.pressKey(1)
    /// manager.pressKey(1)
    /// manager.confirmInput()
    /// ```
    func testConfirmInputCommitsCandidate() {
        let converter = FakeConverter(candidate: "愛")
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: converter)

        var committedText: String?
        var cleared = false

        manager.onCommitText = { text in
            committedText = text
        }
        manager.onClearMarkedText = {
            cleared = true
        }

        manager.pressKey(1)
        manager.pressKey(1)
        manager.confirmInput()

        XCTAssertEqual(committedText, "愛")
        XCTAssertTrue(cleared)
        XCTAssertEqual(manager.composingText, "")
    }
}
