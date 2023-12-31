//
//  EXEmojiKeyboard.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/30/23.
//

import UIKit
import SwiftUI

class EXEmojiKeyboardView: UITextField {
  override var textInputMode: UITextInputMode? {
    return UITextInputMode.activeInputModes.first(where: { $0.primaryLanguage == "emoji" }) ?? super.textInputMode
  }
}

struct EXEmojiKeyboard: UIViewRepresentable {
  @Binding var text: String
  
  func makeUIView(context: Context) -> EXEmojiKeyboardView {
    let textField = EXEmojiKeyboardView()
    textField.delegate = context.coordinator
    return textField
  }
  
  func updateUIView(_ uiView: EXEmojiKeyboardView, context: Context) {
    uiView.textAlignment = .center
    uiView.font = .systemFont(ofSize: 34)
    uiView.text = text
    uiView.tintColor = .clear
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: EXEmojiKeyboard
    
    init(_ parent: EXEmojiKeyboard) {
      self.parent = parent
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      // Limit the input to one character
      if (textField.text?.count ?? 0) + string.count > 1 {
        textField.text = string
        return false
      }
      return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      // Update the binding when editing ends
      parent.text = textField.text ?? ""
    }
  }
}
