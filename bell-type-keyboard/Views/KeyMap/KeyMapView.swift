//
//  KeyMapView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// KeyMapView renders the character map and usage tips.
///
/// Example:
/// ```swift
/// KeyMapView()
/// ```
struct KeyMapView: View {
    let mapper = PokebellInputMapper.shared

    /// Renders the key map screen layout.
    ///
    /// Example:
    /// ```swift
    /// KeyMapView().body
    /// ```
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("変換表")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(RetroTheme.accentGreen)
                        .shadow(color: RetroTheme.accentGreen.opacity(0.5), radius: 5)
                        .padding(.top, 40)
                }

                VStack(spacing: 12) {
                    ForEach(mapper.getAllRows(), id: \.self) { row in
                        let characters = mapper.getCharactersForRow(row: row)
                        if !characters.isEmpty {
                            KeyMapRowView(row: row, characters: characters)
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        TipRowView(
                            icon: "1.circle.fill",
                            text: "2桁の数字で1文字を入力\n例：12 = 「い」"
                        )

                        TipRowView(
                            icon: "arrow.right.circle.fill",
                            text: "1桁目→2桁目の順に押す\n1桁目押下後は「1_」と表示"
                        )

                        TipRowView(
                            icon: "hand.tap.fill",
                            text: "[CLR]ボタンで手動確定\n[DEL]ボタンで削除"
                        )
                    }
                    .padding()
                    .background(RetroTheme.displayBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(RetroTheme.borderColor, lineWidth: 2)
                    )
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
        }
        .background(RetroTheme.bodyBackground)
    }
}

#Preview {
    KeyMapView()
}
