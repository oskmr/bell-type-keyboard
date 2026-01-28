//
//  OnboardingView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RetroTheme.displayBackground)
                            .frame(width: 120, height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(RetroTheme.borderColor, lineWidth: 3)
                            )
                            .shadow(color: RetroTheme.accentGreen.opacity(0.3), radius: 10)

                        Text("📟")
                            .font(.system(size: 60))
                    }

                    Text("POKE-BELL")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(RetroTheme.accentGreen)
                        .shadow(color: RetroTheme.accentGreen.opacity(0.5), radius: 5)

                    Text(">>> KEYBOARD <<<")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(RetroTheme.displayText)
                }
                .padding(.top, 40)

                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text(">> SETUP GUIDE")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(RetroTheme.accentGreen)
                        Spacer()
                        Text("■")
                            .font(.system(size: 20, design: .monospaced))
                            .foregroundColor(RetroTheme.accentGreen)
                            .opacity(0.6)
                    }
                    .padding(.horizontal)

                    SetupStepView(
                        number: 1,
                        title: "設定アプリを開く",
                        description: "iPhoneの「設定」アプリを開きます",
                        icon: "gearshape.fill"
                    )

                    SetupStepView(
                        number: 2,
                        title: "キーボード設定へ移動",
                        description: "一般 → キーボード → キーボード",
                        icon: "keyboard.fill"
                    )

                    SetupStepView(
                        number: 3,
                        title: "キーボードを追加",
                        description: "「新しいキーボードを追加...」をタップして\n「PokebellKeyboard」を選択",
                        icon: "plus.circle.fill"
                    )

                    SetupStepView(
                        number: 4,
                        title: "キーボードを切り替え",
                        description: "テキスト入力時に地球儀アイコン🌐を長押しして\n「PokebellKeyboard」を選択",
                        icon: "globe"
                    )

                    Button(action: {
                        if let url = URL(string: "App-Prefs:root=General&path=Keyboard") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("[")
                            Image(systemName: "gear")
                            Text("OPEN SETTINGS")
                            Text("]")
                        }
                    }
                    .buttonStyle(RetroButtonStyle(isSpecial: true))
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Text("(C) 2026 POKE-BELL-KB")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(RetroTheme.displayTextDim)
                    .padding(.bottom, 40)
            }
        }
        .background(RetroTheme.bodyBackground)
    }
}

struct SetupStepView: View {
    let number: Int
    let title: String
    let description: String
    let icon: String

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
    OnboardingView()
}
