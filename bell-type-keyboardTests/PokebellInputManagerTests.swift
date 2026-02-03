//
//  PokebellInputManagerTests.swift
//  bell-type-keyboardTests
//
//  Created by miseri.osaka on 2026/01/29.
//

import XCTest
@testable import bell_type_keyboard

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

/// PokebellInputManagerTests validates composing and prediction behavior.
final class PokebellInputManagerTests: XCTestCase {
    /// Verifies that composing text updates the candidate list.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: false, converter: FakeConverter(candidate: "愛"))
    /// manager.pressKey(1)
    /// manager.pressKey(1)
    /// ```
    func testPressKeyUpdatesCandidates() {
        let converter = FakeConverter(candidate: "愛")
        let manager = PokebellInputManager(isKeyboardExtension: false, converter: converter)

        manager.pressKey(1)
        manager.pressKey(1)

        XCTAssertEqual(manager.candidates, ["愛"])
        XCTAssertEqual(manager.currentCandidate, "愛")
    }

    /// Verifies that selecting a candidate commits it and clears composing state.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: false, converter: FakeConverter(candidate: "愛"))
    /// manager.selectCandidate("藍")
    /// ```
    func testSelectCandidateCommitsText() {
        let converter = FakeConverter(candidate: "愛")
        let manager = PokebellInputManager(isKeyboardExtension: false, converter: converter)

        manager.selectCandidate("藍")

        XCTAssertEqual(manager.inputText, "藍")
        XCTAssertEqual(manager.composingText, "")
        XCTAssertEqual(manager.candidates, [])
    }
}
