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

            if isDragging {
                flickIndicator
            } else {
                defaultLabel
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
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
                    if let char = character(for: activeDirection) {
                        onCommit(char)
                    }
                    isDragging = false
                    activeDirection = .center
                }
        )
    }

    private var defaultLabel: some View {
        VStack(spacing: 1) {
            if let u = up {
                Text(u)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(RetroTheme.displayText)
            }
            HStack(spacing: 3) {
                if let l = left {
                    Text(l)
                        .font(.system(size: 8))
                        .foregroundColor(RetroTheme.displayText.opacity(0.6))
                }
                Text(center)
                    .font(.system(size: 10))
                    .foregroundColor(RetroTheme.displayText.opacity(0.8))
                if let r = right {
                    Text(r)
                        .font(.system(size: 8))
                        .foregroundColor(RetroTheme.displayText.opacity(0.6))
                }
            }
        }
    }

    private var flickIndicator: some View {
        ZStack {
            if let u = up {
                flickLabel(u, active: activeDirection == .up)
                    .offset(y: -(height * 0.28))
            }
            flickLabel(center, active: activeDirection == .center)
            if let l = left {
                flickLabel(l, active: activeDirection == .left)
                    .offset(x: -18)
            }
            if let r = right {
                flickLabel(r, active: activeDirection == .right)
                    .offset(x: 18)
            }
            if let d = down {
                flickLabel(d, active: activeDirection == .down)
                    .offset(y: height * 0.28)
            }
        }
    }

    private func flickLabel(_ s: String, active: Bool) -> some View {
        Text(s)
            .font(.system(size: active ? 13 : 9, weight: active ? .bold : .regular))
            .foregroundColor(active ? RetroTheme.accentGreen : RetroTheme.displayText.opacity(0.5))
            .animation(.easeInOut(duration: 0.08), value: active)
    }
}
