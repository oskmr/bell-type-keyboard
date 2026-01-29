//
//  PredictionBarView.swift
//  bell-type-keyboard-ex
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// PredictionBarView renders candidate buttons for kana-kanji conversion.
///
/// Example:
/// ```swift
/// PredictionBarView(candidates: ["愛", "藍"], onSelect: { _ in })
/// ```
struct PredictionBarView: View {
    let candidates: [String]
    let onSelect: (String) -> Void

    /// Renders a horizontally scrollable list of candidate buttons.
    ///
    /// Example:
    /// ```swift
    /// PredictionBarView(candidates: ["東京"], onSelect: { _ in }).body
    /// ```
    var body: some View {
        if candidates.isEmpty {
            Color.clear.frame(height: 34)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(candidates.enumerated()), id: \.offset) { _, candidate in
                        Button(action: {
                            onSelect(candidate)
                        }) {
                            Text(candidate)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(RetroTheme.displayText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(RetroTheme.displayBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(RetroTheme.borderColor, lineWidth: 1)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 6)
            }
            .frame(height: 34)
        }
    }
}

#Preview {
    PredictionBarView(candidates: ["愛", "藍", "ある"], onSelect: { _ in })
        .background(RetroTheme.bodyBackground)
}
