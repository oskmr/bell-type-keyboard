//
//  SupportView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/08/28.
//

import SwiftUI

/// A single row in the support list, linking to a web page.
private struct SupportRow: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let urlString: String
}

/// SupportView renders the support sheet as a native settings-style list.
///
/// Example:
/// ```swift
/// SupportView()
/// ```
struct SupportView: View {
    @Environment(\.dismiss) private var dismiss

    private let rows: [SupportRow] = [
        SupportRow(
            icon: "envelope.fill",
            title: "お問い合わせ",
            urlString: "https://rhetorical-week-9f7.notion.site/10bff0495cd983638f640141ebdfea50?pvs=105"
        ),
        SupportRow(
            icon: "lock.shield.fill",
            title: "プライバシーポリシー",
            urlString: "https://sun-pink-516.notion.site/1bc4c4b711e980ad8975c3fbbaafc27d?source=copy_link"
        ),
        SupportRow(
            icon: "doc.text.fill",
            title: "利用規約",
            urlString: "https://sun-pink-516.notion.site/1c54c4b711e98020a28ff182d9d4fd6c?source=copy_link"
        )
    ]

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
                    ForEach(rows) { row in
                        NavigationLink {
                            WebPageView(title: row.title, urlString: row.urlString)
                        } label: {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primary)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: row.icon)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color(.systemBackground))
                                    )

                                Text(row.title)
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .padding(.vertical, 6)
                        }
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
}

#Preview {
    SupportView()
}
