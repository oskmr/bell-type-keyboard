//
//  OnboardingView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

/// OnboardingView renders the setup guide for the keyboard.
///
/// Example:
/// ```swift
/// OnboardingView()
/// ```
struct OnboardingView: View {
    @State private var showSupport = false

    /// Renders the onboarding screen layout.
    ///
    /// Example:
    /// ```swift
    /// OnboardingView().body
    /// ```
    var body: some View {
        RetroTheme.bodyBackground
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
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
                        }
                        .padding(.top, 40)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text(">> SETUP GUIDE")
                                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                                    .foregroundColor(RetroTheme.accentGreen)
                                Spacer()
                                Button(action: { showSupport = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(RetroTheme.accentGreen)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 32)
                            
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
                                description: "「新しいキーボードを追加」をタップ\n「ベル打ちキーボード」を選択",
                                icon: "plus.circle.fill"
                            )
                            SetupStepView(
                                number: 4,
                                title: "キーボードを切り替え",
                                description: "テキスト入力時に地球儀アイコンを長押しし\n「ベル打ちキーボード」を選択",
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
                    }
                }
            )
            .background(RetroTheme.bodyBackground.ignoresSafeArea())
            .sheet(isPresented: $showSupport) {
                SupportView()
            }
    }
}

#Preview {
    OnboardingView()
}
