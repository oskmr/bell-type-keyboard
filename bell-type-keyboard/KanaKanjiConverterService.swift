//
//  KanaKanjiConverterService.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation
import KanaKanjiConverterModuleWithDefaultDictionary

/// KanaKanjiConversionResult summarizes conversion candidates for composing text.
///
/// Example:
/// ```swift
/// let result = KanaKanjiConversionResult(
///     composingText: "あい",
///     candidateText: "愛",
///     candidates: ["愛", "藍"]
/// )
/// ```
struct KanaKanjiConversionResult {
    let composingText: String
    let candidateText: String
    let candidates: [String]
}

/// KanaKanjiConverting abstracts a kana-kanji converter implementation.
///
/// Example:
/// ```swift
/// let converter: KanaKanjiConverting = KanaKanjiConverterService()
/// let result = converter.convert(composingText: "あい")
/// print(result.candidateText)
/// ```
protocol KanaKanjiConverting {
    /// Converts the composing text into candidates.
    ///
    /// Example:
    /// ```swift
    /// let result = converter.convert(composingText: "かんじ")
    /// ```
    ///
    /// - Parameter composingText: The current kana composition.
    /// - Returns: The conversion result with candidates.
    func convert(composingText: String) -> KanaKanjiConversionResult
}

/// KanaKanjiConverterService wraps AzooKeyKanaKanjiConverter for the app.
///
/// Example:
/// ```swift
/// let service = KanaKanjiConverterService()
/// let result = service.convert(composingText: "とうきょう")
/// ```
final class KanaKanjiConverterService: KanaKanjiConverting {
    private let converter: KanaKanjiConverter
    private let options: ConvertRequestOptions

    /// Initializes the converter with the default dictionary and options.
    ///
    /// Example:
    /// ```swift
    /// let service = KanaKanjiConverterService()
    /// ```
    init() {
        let documentURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first

        let safeDocumentURL = documentURL ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let metadata = ConvertRequestOptions.Metadata(versionString: "bell-type-keyboard 1.0")

        converter = KanaKanjiConverter.withDefaultDictionary()
        options = ConvertRequestOptions(
            N_best: 10,
            requireJapanesePrediction: true,
            requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP,
            englishCandidateInRoman2KanaInput: true,
            fullWidthRomanCandidate: false,
            halfWidthKanaCandidate: false,
            learningType: .inputAndOutput,
            maxMemoryCount: 65536,
            shouldResetMemory: false,
            memoryDirectoryURL: safeDocumentURL,
            sharedContainerURL: safeDocumentURL,
            textReplacer: .withDefaultEmojiDictionary(),
            specialCandidateProviders: KanaKanjiConverter.defaultSpecialCandidateProviders,
            metadata: metadata
        )
    }

    /// Converts the composing text and returns best candidates.
    ///
    /// Example:
    /// ```swift
    /// let result = service.convert(composingText: "にほん")
    /// print(result.candidates)
    /// ```
    ///
    /// - Parameter composingText: The current kana composition.
    /// - Returns: The conversion result with the best candidate first.
    func convert(composingText: String) -> KanaKanjiConversionResult {
        guard !composingText.isEmpty else {
            return KanaKanjiConversionResult(
                composingText: composingText,
                candidateText: "",
                candidates: []
            )
        }

        // Build a new composing buffer for each conversion to avoid stale state.
        var buffer = ComposingText()
        buffer.insertAtCursorPosition(composingText, inputStyle: .direct)

        let candidates = converter.requestCandidates(buffer, options: options)
        let texts = candidates.mainResults.map { $0.text }
        let best = texts.first ?? composingText

        return KanaKanjiConversionResult(
            composingText: composingText,
            candidateText: best,
            candidates: texts
        )
    }
}
