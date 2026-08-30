//
//  LicenseEntry.swift
//  bell-type-keyboard
//

import Foundation

/// LicenseEntry describes one third-party component bundled with the app.
///
/// Example:
/// ```swift
/// let entry = LicenseEntry.all.first
/// ```
struct LicenseEntry: Identifiable, Hashable {
    let name: String
    let licenseName: String
    let urlString: String
    let text: String

    var id: String { name }
}

extension LicenseEntry {
    /// Every third-party component shipped in the app, in display order.
    ///
    /// Example:
    /// ```swift
    /// ForEach(LicenseEntry.all) { entry in Text(entry.name) }
    /// ```
    static let all: [LicenseEntry] = [
        LicenseEntry(
            name: "AzooKeyKanaKanjiConverter",
            licenseName: "MIT License",
            urlString: "https://github.com/azooKey/AzooKeyKanaKanjiConverter",
            text: LicenseText.mit(copyright: "2023 Miwa / Ensan")
        ),
        LicenseEntry(
            name: "azooKey Dictionary",
            licenseName: "Apache License 2.0",
            urlString: "https://github.com/azooKey/azooKey_dictionary_storage",
            text: LicenseText.apache2(copyright: "2024 Miwa / ensan")
        ),
        LicenseEntry(
            name: "Jinja",
            licenseName: "MIT License",
            urlString: "https://github.com/johnmai-dev/Jinja",
            text: LicenseText.mit(copyright: "2024 John Mai")
        ),
        LicenseEntry(
            name: "swift-algorithms",
            licenseName: "Apache License 2.0",
            urlString: "https://github.com/apple/swift-algorithms",
            text: LicenseText.apache2WithRuntimeLibraryException
        ),
        LicenseEntry(
            name: "swift-collections",
            licenseName: "Apache License 2.0",
            urlString: "https://github.com/apple/swift-collections",
            text: LicenseText.apache2WithRuntimeLibraryException
        ),
        LicenseEntry(
            name: "swift-numerics",
            licenseName: "Apache License 2.0",
            urlString: "https://github.com/apple/swift-numerics",
            text: LicenseText.apache2WithRuntimeLibraryException
        ),
        LicenseEntry(
            name: "swift-tokenizers",
            licenseName: "Apache License 2.0",
            urlString: "https://github.com/ensan-hcl/swift-tokenizers",
            text: LicenseText.apache2(copyright: "2022 Hugging Face SAS.")
        )
    ]
}
