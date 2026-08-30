//
//  LicenseDetailView.swift
//  bell-type-keyboard
//

import SwiftUI

/// LicenseDetailView shows the full license text of one component.
///
/// Example:
/// ```swift
/// LicenseDetailView(entry: entry)
/// ```
struct LicenseDetailView: View {
    let entry: LicenseEntry

    @ScaledMetric(relativeTo: .footnote) private var textSize: Double = 12

    /// Renders the license detail layout.
    ///
    /// Example:
    /// ```swift
    /// LicenseDetailView(entry: entry).body
    /// ```
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = URL(string: entry.urlString) {
                    Link(destination: url) {
                        Text(entry.urlString)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(minHeight: 44, alignment: .leading)
                }

                Text(entry.text)
                    .font(.system(size: textSize, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LicenseDetailView(entry: LicenseEntry.all[0])
    }
}
