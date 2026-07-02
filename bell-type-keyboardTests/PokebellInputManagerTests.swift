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
struct FakeConverter: KanaKanjiConverting {
    let candidate: String

    /// Returns a fixed candidate for any composing text.
    ///
    /// - Parameter composingText: The composing text.
    /// - Returns: A conversion result with the fixed candidate.
    func convert(composingText: String) async -> KanaKanjiConversionResult {
        KanaKanjiConversionResult(
            composingText: composingText,
            candidateText: candidate,
            candidates: [candidate]
        )
    }
}

/// PokebellInputManagerTests validates composing and conversion behavior.
@MainActor
final class PokebellInputManagerTests: XCTestCase {
    /// Waits until the asynchronous conversion delivers candidates.
    private func waitForCandidates(of manager: PokebellInputManager) async {
        for _ in 0..<100 where manager.candidates.isEmpty {
            await Task.yield()
        }
    }

    // MARK: - App mode (inputText accumulation)

    func testPressKeyUpdatesCandidates() async {
        let manager = PokebellInputManager(isKeyboardExtension: false, converter: FakeConverter(candidate: "愛"))

        manager.pressKey(1)
        manager.pressKey(1)
        await waitForCandidates(of: manager)

        XCTAssertEqual(manager.candidates, ["愛"])
        XCTAssertEqual(manager.currentCandidate, "愛")
    }

    func testSelectCandidateCommitsTextInApp() {
        let manager = PokebellInputManager(isKeyboardExtension: false, converter: FakeConverter(candidate: "愛"))

        manager.selectCandidate("藍")

        XCTAssertEqual(manager.inputText, "藍")
        XCTAssertEqual(manager.composingText, "")
        XCTAssertEqual(manager.candidates, [])
    }

    func testInsertNewlineAppendsToInputText() {
        let manager = PokebellInputManager(isKeyboardExtension: false, converter: nil)

        manager.insertNewline()

        XCTAssertEqual(manager.inputText, "\n")
    }

    // MARK: - Keyboard extension mode (callback commits)

    func testPressKeyUpdatesMarkedTextWithComposingText() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))

        var markedText: String?
        manager.onMarkedTextChange = { text in
            markedText = text
        }

        manager.pressKey(1)
        manager.pressKey(1)

        XCTAssertEqual(markedText, "あ")
    }

    func testConfirmInputCommitsCandidate() async {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))

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
        await waitForCandidates(of: manager)
        manager.confirmInput()

        XCTAssertEqual(committedText, "愛")
        XCTAssertTrue(cleared)
        XCTAssertEqual(manager.composingText, "")
    }

    func testSelectCandidateCommitsText() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))

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

    func testConfirmRawInputCommitsRawKanaIgnoringCandidates() async {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))

        var committedText: String?
        var cleared = false
        manager.onCommitText = { committedText = $0 }
        manager.onClearMarkedText = { cleared = true }

        manager.pressKey(1)
        manager.pressKey(1)
        await waitForCandidates(of: manager)
        manager.confirmRawInput()

        XCTAssertEqual(committedText, "あ")
        XCTAssertTrue(cleared)
        XCTAssertEqual(manager.composingText, "")
    }

    func testInsertNewlineCommitsNewline() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: nil)

        var committedText: String?
        manager.onCommitText = { committedText = $0 }

        manager.insertNewline()

        XCTAssertEqual(committedText, "\n")
    }

    func testInsertSpaceCyclesCandidatesWhileComposing() async {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "愛"))

        var committedText: String?
        manager.onCommitText = { committedText = $0 }

        manager.pressKey(1)
        manager.pressKey(1)
        await waitForCandidates(of: manager)
        manager.insertSpace()

        XCTAssertNil(committedText)
        XCTAssertEqual(manager.selectedCandidateIndex, 0)
        XCTAssertEqual(manager.currentCandidate, "愛")
    }

    func testInsertSpaceCommitsSpaceWhenNotComposing() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: nil)

        var committedText: String?
        manager.onCommitText = { committedText = $0 }

        manager.insertSpace()

        XCTAssertEqual(committedText, " ")
    }

    // MARK: - Modifiers

    func testDakutenAppliedToLastCharacter() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "が"))

        // Input か (21) then dakuten (04)
        manager.pressKey(2)
        manager.pressKey(1)
        manager.pressKey(0)
        manager.pressKey(4)

        XCTAssertEqual(manager.composingText, "が")
    }

    func testHandakutenAppliedToLastCharacter() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "ぱ"))

        // Input は (61) then handakuten (05)
        manager.pressKey(6)
        manager.pressKey(1)
        manager.pressKey(0)
        manager.pressKey(5)

        XCTAssertEqual(manager.composingText, "ぱ")
    }

    func testDakutenIgnoredWhenNoComposingText() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: ""))

        // Press dakuten (04) with no prior input
        manager.pressKey(0)
        manager.pressKey(4)

        XCTAssertEqual(manager.composingText, "")
    }

    func testDakutenIgnoredForIncompatibleCharacter() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "あ"))

        // Input あ (11) then dakuten (04) - あ has no dakuten form
        manager.pressKey(1)
        manager.pressKey(1)
        manager.pressKey(0)
        manager.pressKey(4)

        XCTAssertEqual(manager.composingText, "あ")
    }

    func testSmallKanaAppliedToLastCharacter() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "ょ"))

        // Input よ (85) then small-kana modifier (80)
        manager.pressKey(8)
        manager.pressKey(5)
        manager.pressKey(8)
        manager.pressKey(0)

        XCTAssertEqual(manager.composingText, "ょ")
    }

    func testSmallKanaForTsu() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "っ"))

        // Input つ (43) then small-kana modifier (80)
        manager.pressKey(4)
        manager.pressKey(3)
        manager.pressKey(8)
        manager.pressKey(0)

        XCTAssertEqual(manager.composingText, "っ")
    }

    func testSmallKanaIgnoredForIncompatibleCharacter() {
        let manager = PokebellInputManager(isKeyboardExtension: true, converter: FakeConverter(candidate: "か"))

        // Input か (21) then small-kana modifier (80) - か has no small form
        manager.pressKey(2)
        manager.pressKey(1)
        manager.pressKey(8)
        manager.pressKey(0)

        XCTAssertEqual(manager.composingText, "か")
    }
}
