//
//  PokebellInputManager.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import Foundation
import Combine

final class PokebellInputManager: ObservableObject {
    @Published var inputText: String = ""
    @Published var currentPreview: String = ""

    var onTextChange: ((String) -> Void)?
    var onDeleteBackward: (() -> Void)?

    private var firstDigit: Int?
    private let isKeyboardExtension: Bool

    private let mapper = PokebellInputMapper.shared

    init(isKeyboardExtension: Bool = false) {
        self.isKeyboardExtension = isKeyboardExtension
    }

    func pressKey(_ key: Int) {
        if firstDigit == nil {
            firstDigit = key
            currentPreview = "\(key)_"
        } else {
            if let first = firstDigit {
                if let character = mapper.getCharacter(firstDigit: first, secondDigit: key) {
                    confirmCharacter(character)
                } else {
                    firstDigit = key
                    currentPreview = "\(key)_"
                }
            }
        }
    }

    func deleteLastCharacter() {
        if firstDigit != nil {
            firstDigit = nil
            currentPreview = ""
        } else {
            if isKeyboardExtension {
                onDeleteBackward?()
            } else if !inputText.isEmpty {
                inputText.removeLast()
            }
        }
    }

    func confirmInput() {
        firstDigit = nil
        currentPreview = ""
    }

    private func confirmCharacter(_ character: String) {
        if isKeyboardExtension {
            onTextChange?(character)
        } else {
            inputText += character
        }
        firstDigit = nil
        currentPreview = ""
    }
}
