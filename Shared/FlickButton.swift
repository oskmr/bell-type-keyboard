//
//  FlickButton.swift
//  bell-type-keyboard
//

import SwiftUI

struct FlickButton: View {
    enum Direction { case center, up, down, left, right }

    let center: String
    var up: String? = nil
    var left: String? = nil
    var right: String? = nil
    var down: String? = nil
    var height: Double = 42
    var cornerRadius: Double = 6
    var borderWidth: Double = 1.5
    let onCommit: (String) -> Void

    @State private var activeDirection: Direction = .center
    @State private var isDragging = false

    private func character(for dir: Direction) -> String? {
        switch dir {
        case .center: center
        case .up: up
        case .down: down
        case .left: left
        case .right: right
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isDragging ? RetroTheme.buttonHighlight : RetroTheme.buttonBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(RetroTheme.borderColor, lineWidth: borderWidth)
                )
                .shadow(
                    color: Color.black.opacity(0.4),
                    radius: isDragging ? 1 : 2,
                    x: 0, y: isDragging ? 0.5 : 1
                )

            defaultLabel
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .overlay {
            if isDragging {
                GeometryReader { geo in
                    flickPopup(keySize: geo.size)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .allowsHitTesting(false)
            }
        }
        // Draw the popup above neighboring keys while pressed.
        .zIndex(isDragging ? 100 : 0)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    let t = value.translation
                    let threshold: CGFloat = 12
                    if abs(t.width) < threshold && abs(t.height) < threshold {
                        activeDirection = .center
                    } else if abs(t.width) > abs(t.height) {
                        activeDirection = t.width > 0 ? .right : .left
                    } else {
                        activeDirection = t.height < 0 ? .up : .down
                    }
                }
                .onEnded { _ in
                    // Fall back to the center character for unassigned directions
                    // so a slightly moved tap still inputs the main character.
                    let char = character(for: activeDirection) ?? center
                    onCommit(char)
                    isDragging = false
                    activeDirection = .center
                }
        )
    }

    private var defaultLabel: some View {
        VStack(spacing: 1) {
            if let u = up {
                hintLabel(u)
            }
            HStack(spacing: 4) {
                if let l = left {
                    hintLabel(l)
                }
                Text(center)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(RetroTheme.displayText)
                if let r = right {
                    hintLabel(r)
                }
            }
            if let d = down {
                hintLabel(d)
            }
        }
    }

    private func hintLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 9))
            .foregroundColor(RetroTheme.displayText.opacity(0.5))
    }

    /// Renders iOS-style flick petals popping out around the key while pressed.
    private func flickPopup(keySize: CGSize) -> some View {
        ZStack {
            if let u = up {
                petal(u, active: activeDirection == .up, size: keySize)
                    .offset(y: -keySize.height)
            }
            if let d = down {
                petal(d, active: activeDirection == .down, size: keySize)
                    .offset(y: keySize.height)
            }
            if let l = left {
                petal(l, active: activeDirection == .left, size: keySize)
                    .offset(x: -keySize.width)
            }
            if let r = right {
                petal(r, active: activeDirection == .right, size: keySize)
                    .offset(x: keySize.width)
            }
            petal(center, active: activeDirection == .center, size: keySize)
        }
    }

    private func petal(_ s: String, active: Bool, size: CGSize) -> some View {
        Text(s)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(active ? RetroTheme.displayBackground : RetroTheme.displayText)
            .frame(width: size.width, height: size.height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(active ? RetroTheme.accentGreen : RetroTheme.buttonHighlight)
                    .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(RetroTheme.borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.08), value: active)
    }
}
