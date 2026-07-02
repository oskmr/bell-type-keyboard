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
struct KanaKanjiConversionResult: Sendable {
    let composingText: String
    let candidateText: String
    let candidates: [String]
}

/// KanaKanjiConverting abstracts a kana-kanji converter implementation.
///
/// Example:
/// ```swift
/// let converter: KanaKanjiConverting = KanaKanjiConverterService()
/// let result = await converter.convert(composingText: "あい")
/// print(result.candidateText)
/// ```
protocol KanaKanjiConverting: Sendable {
    /// Converts the composing text into candidates.
    ///
    /// Example:
    /// ```swift
    /// let result = await converter.convert(composingText: "かんじ")
    /// ```
    ///
    /// - Parameter composingText: The current kana composition.
    /// - Returns: The conversion result with candidates.
    func convert(composingText: String) async -> KanaKanjiConversionResult
}

/// KanaKanjiConverterService wraps AzooKeyKanaKanjiConverter behind an actor so
/// conversions run off the main thread and the non-thread-safe converter stays isolated.
///
/// Example:
/// ```swift
/// let service = KanaKanjiConverterService()
/// let result = await service.convert(composingText: "とうきょう")
/// ```
actor KanaKanjiConverterService: KanaKanjiConverting {
    // Loaded lazily on the actor so the heavy dictionary load happens off the
    // main thread, on first conversion rather than at keyboard startup.
    private var loadedConverter: KanaKanjiConverter?
    private var loadedOptions: ConvertRequestOptions?

    private func loadConverterIfNeeded() -> (KanaKanjiConverter, ConvertRequestOptions) {
        if let loadedConverter, let loadedOptions {
            return (loadedConverter, loadedOptions)
        }

        let documentURL = URL.documentsDirectory
        let metadata = ConvertRequestOptions.Metadata(versionString: "bell-type-keyboard 1.0")

        let converter = KanaKanjiConverter.withDefaultDictionary()
        let options = ConvertRequestOptions(
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
            memoryDirectoryURL: documentURL,
            sharedContainerURL: documentURL,
            textReplacer: .withDefaultEmojiDictionary(),
            specialCandidateProviders: KanaKanjiConverter.defaultSpecialCandidateProviders,
            metadata: metadata
        )

        loadedConverter = converter
        loadedOptions = options
        return (converter, options)
    }

    /// Converts the composing text and returns best candidates.
    ///
    /// Example:
    /// ```swift
    /// let result = await service.convert(composingText: "にほん")
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

        let (converter, options) = loadConverterIfNeeded()

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
