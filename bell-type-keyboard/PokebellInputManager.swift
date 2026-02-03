//
//  PokebellInputManager.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation
import Combine

/// PokebellInputManager manages digit input and kana-kanji prediction for the app.
///
/// Example:
/// ```swift
/// let manager = PokebellInputManager(converter: KanaKanjiConverterService())
/// manager.pressKey(1)
/// manager.pressKey(2)
/// ```
final class PokebellInputManager: ObservableObject {
    @Published var inputText: String = ""
    @Published var currentPreview: String = ""
    @Published var composingText: String = ""
    @Published var currentCandidate: String = ""
    @Published var candidates: [String] = []

    var onTextChange: ((String) -> Void)?
    var onDeleteBackward: (() -> Void)?

    private var firstDigit: Int?
    private let isKeyboardExtension: Bool
    private let converter: KanaKanjiConverting?

    private let mapper = PokebellInputMapper.shared

    /// Initializes the input manager with an optional converter.
    ///
    /// Example:
    /// ```swift
    /// let manager = PokebellInputManager(isKeyboardExtension: false, converter: KanaKanjiConverterService())
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
                applyVoicedMark(isDakuten: true)
            } else if mapper.isHandakuten(firstDigit: first, secondDigit: key) {
                applyVoicedMark(isDakuten: false)
            } else if let character = mapper.getCharacter(firstDigit: first, secondDigit: key) {
                confirmCharacter(character)
            } else {
                firstDigit = key
                currentPreview = "\(key)_"
            }
        }
    }

    private func applyVoicedMark(isDakuten: Bool) {
        firstDigit = nil
        currentPreview = ""

        guard !isKeyboardExtension else { return }

        if !composingText.isEmpty {
            guard let lastChar = composingText.last else { return }
            let converted = isDakuten
                ? mapper.applyDakuten(to: lastChar)
                : mapper.applyHandakuten(to: lastChar)
            guard let converted else { return }
            composingText.removeLast()
            composingText.append(converted)
            updateConversion()
        } else if !inputText.isEmpty {
            guard let lastChar = inputText.last else { return }
            let converted = isDakuten
                ? mapper.applyDakuten(to: lastChar)
                : mapper.applyHandakuten(to: lastChar)
            guard let converted else { return }
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

        if isKeyboardExtension {
            onDeleteBackward?()
            return
        }

        if !composingText.isEmpty {
            composingText.removeLast()
            updateConversion()
        } else if !inputText.isEmpty {
            inputText.removeLast()
        }
    }

    /// Confirms the current composing text and clears preview state.
    ///
    /// Example:
    /// ```swift
    /// manager.confirmInput()
    /// ```
    func confirmInput() {
        firstDigit = nil
        currentPreview = ""

        guard !isKeyboardExtension else {
            return
        }

        if !composingText.isEmpty {
            let commitText = currentCandidate.isEmpty ? composingText : currentCandidate
            inputText += commitText
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
        guard !isKeyboardExtension else {
            return
        }

        inputText += candidate
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
            onTextChange?(character)
        } else {
            composingText += character
            updateConversion()
        }
        firstDigit = nil
        currentPreview = ""
    }

    /// Updates the candidate cache for the current composing string.
    ///
    /// Example:
    /// ```swift
    /// manager.pressKey(1)
    /// manager.pressKey(1)
    /// ```
    private func updateConversion() {
        if composingText.isEmpty {
            currentCandidate = ""
            candidates = []
            return
        }

        let result = converter?.convert(composingText: composingText)
        currentCandidate = result?.candidateText ?? composingText
        candidates = result?.candidates ?? [composingText]
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
