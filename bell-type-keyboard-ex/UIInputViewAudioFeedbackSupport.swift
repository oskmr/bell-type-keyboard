//
//  UIInputViewAudioFeedbackSupport.swift
//  bell-type-keyboard-ex
//

import UIKit

/// Enables standard keyboard click sounds for `UIDevice.playInputClick()`
/// inside the keyboard extension. The clicks respect the system
/// "Keyboard Clicks" sound setting and require no full access.
extension UIInputView: @retroactive UIInputViewAudioFeedback {
    public var enableInputClicksWhenVisible: Bool { true }
}
