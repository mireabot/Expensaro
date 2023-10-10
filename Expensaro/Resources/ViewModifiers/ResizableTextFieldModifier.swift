//
//  ResizableTextFieldModifier.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/10/23.
//

import SwiftUI

struct MultilineSubmitViewModifier: ViewModifier {
  
  init(
    text: Binding<String>,
    submitLabel: SubmitLabel,
    onSubmit: @escaping () -> Void
  ) {
    self._text = text
    self.submitLabel = submitLabel
    self.onSubmit = onSubmit
  }
  
  @Binding
  private var text: String
  
  private let submitLabel: SubmitLabel
  private let onSubmit: () -> Void
  
  @FocusState
  private var isFocused: Bool
  
  func body(content: Content) -> some View {
    content
      .focused($isFocused)
      .submitLabel(submitLabel)
      .onChange(of: text) { newValue in
        guard isFocused else { return }
        guard newValue.contains("\n") else { return }
        isFocused = false
        text = newValue.replacingOccurrences(of: "\n", with: "")
        onSubmit()
      }
  }
}
