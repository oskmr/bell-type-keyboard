//
//  KeyMapView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct KeyMapView: View {
    let mapper = PokebellInputMapper.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("CHARACTER MAP")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(RetroTheme.accentGreen)
                        .shadow(color: RetroTheme.accentGreen.opacity(0.5), radius: 5)
                        .padding(.top, 40)

                    Text(">> PRESS COUNT >>")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(RetroTheme.displayText)
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
                    HStack {
                        Text(">> USAGE TIPS")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(RetroTheme.accentGreen)
                        Spacer()
                    }

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
                            text: "[OK]ボタンで手動確定\n[DEL]ボタンで削除"
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

                Text("(C) 2026 POKE-BELL-KB")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(RetroTheme.displayTextDim)
                    .padding(.bottom, 40)
            }
        }
        .background(RetroTheme.bodyBackground)
    }
}

struct KeyMapRowView: View {
    let row: Int
    let characters: [(code: String, char: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(RetroTheme.buttonBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(RetroTheme.borderColor, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                        .frame(width: 50, height: 50)

                    Text("\(row)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(RetroTheme.displayText)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(RetroTheme.accentGreen)

                Text("ROW \(row)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(characters, id: \.code) { item in
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RetroTheme.displayBackground)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(RetroTheme.accentGreen.opacity(0.3), lineWidth: 1)
                                    )

                                Text(item.char)
                                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                                    .foregroundColor(RetroTheme.displayText)
                            }

                            Text(item.code)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(RetroTheme.displayTextDim)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RetroTheme.buttonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(RetroTheme.borderColor, lineWidth: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .cornerRadius(12)
    }
}

struct TipRowView: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(RetroTheme.accentGreen)
                .frame(width: 30)

            Text(text)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(RetroTheme.displayText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    KeyMapView()
}
