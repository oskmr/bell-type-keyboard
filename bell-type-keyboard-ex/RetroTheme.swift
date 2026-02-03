//
//  RetroTheme.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

struct RetroTheme {
    static let displayBackground = Color(red: 0.1, green: 0.15, blue: 0.1)
    static let displayText = Color(red: 0.4, green: 1.0, blue: 0.4)
    static let displayTextDim = Color(red: 0.2, green: 0.5, blue: 0.2)

    static let buttonBackground = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let buttonHighlight = Color(red: 0.3, green: 0.3, blue: 0.3)
    static let buttonPressed = Color(red: 0.05, green: 0.05, blue: 0.05)

    static let accentGreen = Color(red: 0.3, green: 0.9, blue: 0.3)
    static let borderColor = Color(red: 0.25, green: 0.25, blue: 0.25)

    static let bodyBackground = displayBackground
    static let keyboardSystemBackground = Color(UIColor.systemGray5)
}

struct RetroDisplayModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(RetroTheme.displayText)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RetroTheme.displayBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(RetroTheme.borderColor, lineWidth: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: RetroTheme.displayText.opacity(0.3), radius: 8, x: 0, y: 0)
            .cornerRadius(8)
    }
}

struct RetroButtonStyle: ButtonStyle {
    var isSpecial: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(isSpecial ? RetroTheme.displayBackground : RetroTheme.displayText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    if isSpecial {
                        RetroTheme.accentGreen
                    } else {
                        configuration.isPressed ? RetroTheme.buttonPressed : RetroTheme.buttonBackground
                    }

                    if !configuration.isPressed {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear,
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        configuration.isPressed ? Color.clear : RetroTheme.borderColor,
                        lineWidth: 2
                    )
            )
            .cornerRadius(8)
            .shadow(
                color: isSpecial ? RetroTheme.accentGreen.opacity(0.5) : Color.black.opacity(0.5),
                radius: configuration.isPressed ? 2 : 4,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CompactRetroButtonStyle: ButtonStyle {
    var isSpecial: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isSpecial ? RetroTheme.displayBackground : RetroTheme.displayText)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                ZStack {
                    if isSpecial {
                        RetroTheme.accentGreen
                    } else {
                        configuration.isPressed ? RetroTheme.buttonPressed : RetroTheme.buttonBackground
                    }

                    if !configuration.isPressed {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear,
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        configuration.isPressed ? Color.clear : RetroTheme.borderColor,
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(6)
            .shadow(
                color: isSpecial ? RetroTheme.accentGreen.opacity(0.4) : Color.black.opacity(0.4),
                radius: configuration.isPressed ? 1 : 2,
                x: 0,
                y: configuration.isPressed ? 0.5 : 1
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

extension View {
    func retroDisplay() -> some View {
        modifier(RetroDisplayModifier())
    }
}
