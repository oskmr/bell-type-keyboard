//
//  LicenseRowView.swift
//  bell-type-keyboard
//

import SwiftUI

/// LicenseRowView renders one third-party component as a list row.
///
/// Example:
/// ```swift
/// LicenseRowView(entry: entry)
/// ```
struct LicenseRowView: View {
    let entry: LicenseEntry

    /// Renders the row layout.
    ///
    /// Example:
    /// ```swift
    /// LicenseRowView(entry: entry).body
    /// ```
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.name)
                .font(.body)

            Text(entry.licenseName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44, alignment: .leading)
    }
}

#Preview {
    List {
        LicenseRowView(entry: LicenseEntry.all[0])
    }
}
