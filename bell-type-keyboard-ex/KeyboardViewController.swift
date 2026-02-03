//
//  KeyboardViewController.swift
//  bell-type-keyboard-ex
//
//  Created by miseri.osaka on 2026/01/29.
//

import UIKit
import SwiftUI

/// KeyboardViewController hosts the SwiftUI keyboard extension view.
///
/// Example:
/// ```swift
/// let controller = KeyboardViewController()
/// ```
@MainActor
class KeyboardViewController: UIInputViewController {
    private let converterService = KanaKanjiConverterService()
    private lazy var inputManager = PokebellInputManager(
        isKeyboardExtension: true,
        converter: converterService
    )
    private var hostingController: UIHostingController<KeyboardExtensionView>?

    /// Updates constraints when the keyboard view changes size.
    ///
    /// Example:
    /// ```swift
    /// controller.updateViewConstraints()
    /// ```
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    /// Configures callbacks and hosts the SwiftUI keyboard view.
    ///
    /// Example:
    /// ```swift
    /// controller.viewDidLoad()
    /// ```
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(RetroTheme.keyboardSystemBackground)
        // Remove the system input assistant bar (gray strip above the keyboard).
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []

        inputManager.onTextChange = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
        }

        inputManager.onMarkedTextChange = { [weak self] text in
            let selectedRange = NSRange(location: text.count, length: 0)
            self?.textDocumentProxy.setMarkedText(text, selectedRange: selectedRange)
        }

        inputManager.onCommitText = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
        }

        inputManager.onClearMarkedText = { [weak self] in
            self?.textDocumentProxy.unmarkText()
        }

        inputManager.onDeleteBackward = { [weak self] in
            self?.textDocumentProxy.deleteBackward()
        }

        let keyboardView = KeyboardExtensionView(inputManager: inputManager)
        let hosting = UIHostingController(rootView: keyboardView)
        // Match the host view background to remove any top padding tint mismatch.
        hosting.view.backgroundColor = UIColor(RetroTheme.keyboardSystemBackground)
        hosting.view.isOpaque = true

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

    /// Lays out subviews for the keyboard UI.
    ///
    /// Example:
    /// ```swift
    /// controller.viewWillLayoutSubviews()
    /// ```
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    /// Prepares for input changes in the host app.
    ///
    /// Example:
    /// ```swift
    /// controller.textWillChange(nil)
    /// ```
    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
    }

    /// Responds to changes in the host app's text input.
    ///
    /// Example:
    /// ```swift
    /// controller.textDidChange(nil)
    /// ```
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
    }
}
