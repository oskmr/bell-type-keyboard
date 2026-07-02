//
//  PredictionBarView.swift
//  bell-type-keyboard
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
    var selectedIndex: Int? = nil
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
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(Array(candidates.enumerated()), id: \.offset) { index, candidate in
                            candidateButton(candidate, isSelected: index == selectedIndex)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, 6)
                    .background(Color.clear)
                }
                .scrollIndicators(.hidden)
                .frame(height: 34)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .onChange(of: selectedIndex) { _, newValue in
                    guard let newValue else { return }
                    withAnimation(.easeInOut(duration: 0.15)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }

    private func candidateButton(_ candidate: String, isSelected: Bool) -> some View {
        Button(action: { onSelect(candidate) }) {
            Text(candidate)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(isSelected ? RetroTheme.accentGreen : RetroTheme.displayText)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(RetroTheme.displayBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? RetroTheme.accentGreen : RetroTheme.borderColor,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .cornerRadius(8)
        }
    }
}

#Preview {
    PredictionBarView(candidates: ["愛", "藍", "ある"], selectedIndex: 1, onSelect: { _ in })
        .background(RetroTheme.bodyBackground)
}
