//
//  DemoView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct DemoView: View {
    @StateObject private var inputManager = PokebellInputManager()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Text("POKE-BELL DEMO")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(RetroTheme.accentGreen)
                    .padding(.top, 20)
                    .shadow(color: RetroTheme.accentGreen.opacity(0.5), radius: 5)

                Text(">> 2-DIGIT INPUT >>")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(RetroTheme.displayText)

                Text("例: 12 = 「い」")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(RetroTheme.displayTextDim)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("OUTPUT:")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(RetroTheme.displayTextDim)
                        Spacer()
                        if !inputManager.currentPreview.isEmpty {
                            Text("■")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(RetroTheme.accentGreen)
                                .opacity(0.8)
                        }
                    }
                    .padding(.horizontal, 4)

                    Text(inputManager.inputText + inputManager.currentPreview + (inputManager.currentPreview.isEmpty ? "" : "_"))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(RetroTheme.displayText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 60)
                        .padding(8)

                    if !inputManager.currentPreview.isEmpty {
                        HStack {
                            Text(">> INPUT: [\(inputManager.currentPreview)]")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(RetroTheme.accentGreen)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .retroDisplay()
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .background(RetroTheme.bodyBackground)

            Spacer()

            PokebellKeyboardView(inputManager: inputManager)
        }
        .background(RetroTheme.bodyBackground)
    }
}
