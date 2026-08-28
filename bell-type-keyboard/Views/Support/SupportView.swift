//
//  SupportView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/08/28.
//

import SwiftUI

/// SupportView renders the support sheet as a native settings-style list.
///
/// Example:
/// ```swift
/// SupportView()
/// ```
struct SupportView: View {
    private let privacyPolicyURL = "https://sun-pink-516.notion.site/1bc4c4b711e980ad8975c3fbbaafc27d?source=copy_link"
    private let termsOfServiceURL = "https://sun-pink-516.notion.site/1c54c4b711e98020a28ff182d9d4fd6c?source=copy_link"

    @Environment(\.dismiss) private var dismiss

    /// Renders the support screen layout.
    ///
    /// Example:
    /// ```swift
    /// SupportView().body
    /// ```
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ContactFormView()
                    } label: {
                        rowLabel(icon: "envelope.fill", title: "お問い合わせ")
                    }

                    NavigationLink {
                        WebPageView(title: "プライバシーポリシー", urlString: privacyPolicyURL)
                    } label: {
                        rowLabel(icon: "lock.shield.fill", title: "プライバシーポリシー")
                    }

                    NavigationLink {
                        WebPageView(title: "利用規約", urlString: termsOfServiceURL)
                    } label: {
                        rowLabel(icon: "doc.text.fill", title: "利用規約")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("サポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                }
            }
        }
    }

    private func rowLabel(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.systemBackground))
                )

            Text(title)
                .font(.system(size: 17, weight: .semibold))
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SupportView()
}
