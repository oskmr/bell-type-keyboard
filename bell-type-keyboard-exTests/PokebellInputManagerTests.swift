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

    /// Verifies that selecting a candidate commits it and clears composing state.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))
    /// manager.selectCandidate("藍")
    /// ```
    func testSelectCandidateCommitsText() {
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

        manager.selectCandidate("藍")

        XCTAssertEqual(committedText, "藍")
        XCTAssertTrue(cleared)
        XCTAssertEqual(manager.composingText, "")
        XCTAssertEqual(manager.candidates, [])
    }

    func testDakutenAppliedToLastCharacter() {
        let converter = FakeConverter(candidate: "が")
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: converter)

        // Input か (21) then dakuten (04)
        manager.pressKey(2)
        manager.pressKey(1)
        manager.pressKey(0)
        manager.pressKey(4)

        XCTAssertEqual(manager.composingText, "が")
    }

    func testHandakutenAppliedToLastCharacter() {
        let converter = FakeConverter(candidate: "ぱ")
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: converter)

        // Input は (61) then handakuten (05)
        manager.pressKey(6)
        manager.pressKey(1)
        manager.pressKey(0)
        manager.pressKey(5)

        XCTAssertEqual(manager.composingText, "ぱ")
    }

    func testDakutenIgnoredWhenNoComposingText() {
        let converter = FakeConverter(candidate: "")
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: converter)

        // Press dakuten (04) with no prior input
        manager.pressKey(0)
        manager.pressKey(4)

        XCTAssertEqual(manager.composingText, "")
    }

    func testDakutenIgnoredForIncompatibleCharacter() {
        let converter = FakeConverter(candidate: "あ")
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: converter)

        // Input あ (11) then dakuten (04) - あ has no dakuten form
        manager.pressKey(1)
        manager.pressKey(1)
        manager.pressKey(0)
        manager.pressKey(4)

        XCTAssertEqual(manager.composingText, "あ")
    }
}
