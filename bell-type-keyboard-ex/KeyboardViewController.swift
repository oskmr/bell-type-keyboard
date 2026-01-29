//
//  KeyboardViewController.swift
//  bell-type-keyboard-ex
//
//  Created by miseri.osaka on 2026/01/29.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    private var inputManager = PokebellInputManager(isKeyboardExtension: true)
    private var hostingController: UIHostingController<KeyboardExtensionView>?

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputManager.onTextChange = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
        }

        inputManager.onDeleteBackward = { [weak self] in
            self?.textDocumentProxy.deleteBackward()
        }

        let keyboardView = KeyboardExtensionView(inputManager: inputManager)
        let hosting = UIHostingController(rootView: keyboardView)

        addChild(hosting)
        view.addSubview(hosting.view)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hosting.didMove(toParent: self)
        hostingController = hosting
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
    }
}
