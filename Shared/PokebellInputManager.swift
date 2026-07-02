//
//  PokebellInputManager.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation
import Observation

/// PokebellInputManager manages digit input and kana-kanji conversion.
///
/// In the keyboard extension it commits text through the callbacks; in the
/// host app it accumulates text into `inputText` for the demo screen.
///
/// Example:
/// ```swift
/// let manager = PokebellInputManager(isKeyboardExtension: true, converter: KanaKanjiConverterService())
/// manager.pressKey(1)
/// manager.pressKey(2)
/// ```
@MainActor
@Observable
final class PokebellInputManager {
    private(set) var inputText = ""
    private(set) var currentPreview = ""
    private(set) var composingText = ""
    private(set) var currentCandidate = ""
    private(set) var candidates: [String] = []
    private(set) var selectedCandidateIndex: Int?

    @ObservationIgnored var onMarkedTextChange: ((String) -> Void)?
    @ObservationIgnored var onCommitText: ((String) -> Void)?
    @ObservationIgnored var onClearMarkedText: (() -> Void)?
    @ObservationIgnored var onDeleteBackward: (() -> Void)?

    private var firstDigit: Int?
    private var conversionGeneration = 0
    private let isKeyboardExtension: Bool
    private let converter: KanaKanjiConverting?

    private let mapper = PokebellInputMapper.shared

    /// Initializes the input manager with an optional converter.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: false, converter: nil)
    /// ```
    init(isKeyboardExtension: Bool = false, converter: KanaKanjiConverting? = nil) {
        self.isKeyboardExtension = isKeyboardExtension
        self.converter = converter
    }

    /// Handles a numeric key press and updates the preview or confirms a character.
    ///
    /// Example:
    /// ```swift
    /// manager.pressKey(1)
    /// manager.pressKey(2)
    /// ```
    /// - Parameter key: The digit key that was pressed.
    func pressKey(_ key: Int) {
        if firstDigit == nil {
            firstDigit = key
            currentPreview = "\(key)_"
        } else if let first = firstDigit {
            if mapper.isDakuten(firstDigit: first, secondDigit: key) {
                applyModifier { self.mapper.applyDakuten(to: $0) }
            } else if mapper.isHandakuten(firstDigit: first, secondDigit: key) {
                applyModifier { self.mapper.applyHandakuten(to: $0) }
            } else if mapper.isSmallKana(firstDigit: first, secondDigit: key) {
                applyModifier { self.mapper.applySmallKana(to: $0) }
            } else if let character = mapper.getCharacter(firstDigit: first, secondDigit: key) {
                confirmCharacter(character)
            } else {
                firstDigit = key
                currentPreview = "\(key)_"
            }
        }
    }

    /// Applies the small kana modifier to the last character.
    func applySmallKana() {
        applyModifier { mapper.applySmallKana(to: $0) }
    }

    /// Inserts a space, or cycles to the next candidate while composing.
    func insertSpace() {
        firstDigit = nil
        currentPreview = ""

        if !composingText.isEmpty {
            selectNextCandidate()
        } else if isKeyboardExtension {
            onCommitText?(" ")
        } else {
            inputText += " "
        }
    }

    /// Inserts a newline character.
    func insertNewline() {
        firstDigit = nil
        currentPreview = ""
        if isKeyboardExtension {
            onCommitText?("\n")
        } else {
            inputText += "\n"
        }
    }

    /// Inserts the given symbol character.
    func insertSymbol(_ char: String) {
        firstDigit = nil
        currentPreview = ""
        if isKeyboardExtension {
            onCommitText?(char)
        } else {
            inputText += char
        }
    }

    /// Selects the next conversion candidate, wrapping around at the end.
    func selectNextCandidate() {
        guard !candidates.isEmpty else { return }

        let next = if let selectedCandidateIndex {
            (selectedCandidateIndex + 1) % candidates.count
        } else {
            0
        }
        selectedCandidateIndex = next
        currentCandidate = candidates[next]
    }

    /// Commits the composing text as raw kana, ignoring conversion candidates.
    func confirmRawInput() {
        commitComposing(composingText)
    }

    /// Applies a character transform (dakuten, handakuten, or small kana) to
    /// the last composed character, if the transform produces a result.
    private func applyModifier(_ convert: (Character) -> Character?) {
        firstDigit = nil
        currentPreview = ""

        if !composingText.isEmpty {
            guard let lastChar = composingText.last, let converted = convert(lastChar) else { return }
            composingText.removeLast()
            composingText.append(converted)
            updateConversion()
        } else if !isKeyboardExtension, !inputText.isEmpty {
            guard let lastChar = inputText.last, let converted = convert(lastChar) else { return }
            inputText.removeLast()
            inputText.append(converted)
        }
    }

    /// Deletes the last character or clears the pending digit.
    ///
    /// Example:
    /// ```swift
    /// manager.deleteLastCharacter()
    /// ```
    func deleteLastCharacter() {
        if firstDigit != nil {
            firstDigit = nil
            currentPreview = ""
            return
        }

        if !composingText.isEmpty {
            composingText.removeLast()
            updateConversion()
        } else if isKeyboardExtension {
            onDeleteBackward?()
        } else if !inputText.isEmpty {
            inputText.removeLast()
        }
    }

    /// Commits the current candidate (or raw kana) and clears the composing state.
    ///
    /// Example:
    /// ```swift
    /// manager.confirmInput()
    /// ```
    func confirmInput() {
        commitComposing(currentCandidate.isEmpty ? composingText : currentCandidate)
    }

    /// Commits the given text for the current composition and clears the composing state.
    private func commitComposing(_ text: String) {
        firstDigit = nil
        currentPreview = ""

        guard !composingText.isEmpty else { return }

        if isKeyboardExtension {
            onCommitText?(text)
            onClearMarkedText?()
        } else {
            inputText += text
        }
        clearComposingState()
    }

    /// Selects a candidate and commits it immediately.
    ///
    /// Example:
    /// ```swift
    /// manager.selectCandidate("愛")
    /// ```
    /// - Parameter candidate: The candidate text to commit.
    func selectCandidate(_ candidate: String) {
        if isKeyboardExtension {
            onCommitText?(candidate)
            onClearMarkedText?()
        } else {
            inputText += candidate
        }
        clearComposingState()
    }

    /// Appends a mapped character to the composing text.
    ///
    /// - Parameter character: The mapped kana character.
    private func confirmCharacter(_ character: String) {
        composingText += character
        updateConversion()
        firstDigit = nil
        currentPreview = ""
    }

    /// Updates the marked text immediately and requests candidates asynchronously.
    ///
    /// Conversion runs on the converter actor; a generation counter discards
    /// results that arrive after the composing text has changed again.
    private func updateConversion() {
        selectedCandidateIndex = nil

        guard !composingText.isEmpty else {
            clearComposingState()
            if isKeyboardExtension {
                onClearMarkedText?()
            }
            return
        }

        if isKeyboardExtension {
            // Keep marked text as raw composing text to avoid auto-committing conversions.
            onMarkedTextChange?(composingText)
        }

        // Fall back to the raw kana until (or unless) a conversion result arrives.
        currentCandidate = composingText

        guard let converter else {
            candidates = [composingText]
            return
        }

        conversionGeneration += 1
        let generation = conversionGeneration
        let text = composingText
        Task {
            let result = await converter.convert(composingText: text)
            guard generation == conversionGeneration else { return }
            currentCandidate = result.candidateText
            candidates = result.candidates
        }
    }

    /// Clears the composing state, candidate cache, and any in-flight conversion.
    private func clearComposingState() {
        conversionGeneration += 1
        composingText = ""
        currentCandidate = ""
        candidates = []
        selectedCandidateIndex = nil
    }
}
