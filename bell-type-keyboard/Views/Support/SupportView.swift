//
//  SupportView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/08/28.
//

import SwiftUI

/// SupportView renders the support / contact sheet.
///
/// Example:
/// ```swift
/// SupportView()
/// ```
struct SupportView: View {
    @Environment(\.dismiss) private var dismiss

    private let supportEmail = "cs@fracaso.app"

    /// Renders the support screen layout.
    ///
    /// Example:
    /// ```swift
    /// SupportView().body
    /// ```
    var body: some View {
        RetroTheme.bodyBackground
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text(">> SUPPORT")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(RetroTheme.accentGreen)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 32)

                    Button(action: {
                        if let url = URL(string: "mailto:\(supportEmail)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RetroTheme.displayBackground)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(RetroTheme.accentGreen, lineWidth: 2)
                                    )

                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(RetroTheme.accentGreen)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("お問い合わせ")
                                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                    .foregroundColor(RetroTheme.displayText)

                                Text(supportEmail)
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(RetroTheme.displayTextDim)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(RetroTheme.displayTextDim)
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: { dismiss() }) {
                        HStack {
                            Text("[")
                            Text("CLOSE")
                            Text("]")
                        }
                    }
                    .buttonStyle(RetroButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            )
            .background(RetroTheme.bodyBackground.ignoresSafeArea())
    }
}

#Preview {
    SupportView()
}
