//
//  SetupStepView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// SetupStepView renders a single onboarding step.
///
/// Example:
/// ```swift
/// SetupStepView(number: 1, title: "設定アプリを開く", description: "iPhoneの「設定」アプリを開きます", icon: "gearshape.fill")
/// ```
struct SetupStepView: View {
    let number: Int
    let title: String
    let description: String
    let icon: String

    /// Renders the step row with number, icon, and description.
    ///
    /// Example:
    /// ```swift
    /// SetupStepView(number: 2, title: "キーボード設定へ移動", description: "一般 → キーボード → キーボード", icon: "keyboard.fill").body
    /// ```
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(RetroTheme.displayBackground)
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(RetroTheme.accentGreen, lineWidth: 2)
                    )

                Text("\(number)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(RetroTheme.accentGreen)
                        .font(.system(size: 16))

                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(RetroTheme.displayText)
                }

                Text(description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(RetroTheme.displayTextDim)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    SetupStepView(
        number: 1,
        title: "設定アプリを開く",
        description: "iPhoneの「設定」アプリを開きます",
        icon: "gearshape.fill"
    )
}
