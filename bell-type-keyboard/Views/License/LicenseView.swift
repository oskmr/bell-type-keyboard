//
//  LicenseView.swift
//  bell-type-keyboard
//

import SwiftUI

/// LicenseView lists the third-party licenses bundled with the app.
///
/// Example:
/// ```swift
/// LicenseView()
/// ```
struct LicenseView: View {
    /// Renders the license list layout.
    ///
    /// Example:
    /// ```swift
    /// LicenseView().body
    /// ```
    var body: some View {
        List {
            Section {
                ForEach(LicenseEntry.all) { entry in
                    NavigationLink {
                        LicenseDetailView(entry: entry)
                    } label: {
                        LicenseRowView(entry: entry)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ライセンス")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LicenseView()
    }
}
