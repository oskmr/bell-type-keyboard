//
//  PokebellInputManager.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation
import Combine

/// PokebellInputManager manages digit input and optional kana-kanji conversion.
///
/// Example:
/// ```swift
/// let manager = PokebellInputManager(isKeyboardExtension: true, converter: KanaKanjiConverterService())
/// manager.pressKey(1)
/// manager.pressKey(2)
/// ```
class PokebellInputManager: ObservableObject {
    @Published var inputText: String = ""
    @Published var currentPreview: String = ""
    @Published var composingText: String = ""
    @Published var currentCandidate: String = ""
    @Published var candidates: [String] = []

    var onTextChange: ((String) -> Void)?
    var onMarkedTextChange: ((String) -> Void)?
    var onCommitText: ((String) -> Void)?
    var onClearMarkedText: (() -> Void)?
    var onDeleteBackward: (() -> Void)?

    private var firstDigit: Int?
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
            if let character = mapper.getCharacter(firstDigit: first, secondDigit: key) {
                confirmCharacter(character)
            } else {
                firstDigit = key
                currentPreview = "\(key)_"
            }
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

        if isKeyboardExtension {
            if !composingText.isEmpty {
                composingText.removeLast()
                updateConversion()
            } else {
                onDeleteBackward?()
            }
        } else if !inputText.isEmpty {
            inputText.removeLast()
        }
    }

    /// Confirms the current composing text or clears the pending digit.
    ///
    /// Example:
    /// ```swift
    /// manager.confirmInput()
    /// ```
    func confirmInput() {
        firstDigit = nil
        currentPreview = ""

        guard isKeyboardExtension else {
            return
        }

        // Commit the best candidate and clear the composing state.
        if !composingText.isEmpty {
            let commitText = currentCandidate.isEmpty ? composingText : currentCandidate
            onCommitText?(commitText)
            onClearMarkedText?()
            clearComposingState()
        }
    }

    /// Selects a candidate and commits it immediately.
    ///
    /// Example:
    /// ```swift
    /// manager.selectCandidate("愛")
    /// ```
    /// - Parameter candidate: The candidate text to commit.
    func selectCandidate(_ candidate: String) {
        guard isKeyboardExtension else {
            return
        }

        currentCandidate = candidate
        onCommitText?(candidate)
        onClearMarkedText?()
        clearComposingState()
    }

    /// Confirms a mapped character and updates composing state.
    ///
    /// Example:
    /// ```swift
    /// manager.pressKey(1)
    /// manager.pressKey(1)
    /// ```
    /// - Parameter character: The mapped kana character.
    private func confirmCharacter(_ character: String) {
        if isKeyboardExtension {
            composingText += character
            updateConversion()
        } else {
            inputText += character
            onTextChange?(character)
        }
        firstDigit = nil
        currentPreview = ""
    }

    /// Updates the candidate cache and marked text for the current composing string.
    ///
    /// Example:
    /// ```swift
    /// manager.pressKey(1)
    /// manager.pressKey(1)
    /// ```
    private func updateConversion() {
        guard isKeyboardExtension else {
            return
        }

        if composingText.isEmpty {
            currentCandidate = ""
            candidates = []
            onClearMarkedText?()
            return
        }

        let result = converter?.convert(composingText: composingText)
        currentCandidate = result?.candidateText ?? composingText
        candidates = result?.candidates ?? [composingText]

        // Keep marked text as raw composing text to avoid auto-committing conversions.
        onMarkedTextChange?(composingText)
    }

    /// Clears the composing state and candidate cache.
    ///
    /// Example:
    /// ```swift
    /// manager.confirmInput()
    /// ```
    private func clearComposingState() {
        composingText = ""
        currentCandidate = ""
        candidates = []
    }
}
