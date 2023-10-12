//
//  View+Extensions.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI

extension View {
  /// Appling default margins for View
  func applyMargins() -> some View {
    self.padding([.leading, .trailing], 16)
  }
  
  /// Checks height of view
  func readHeight() -> some View {
    self.modifier(ReadHeightModifier())
  }
  
  
  /// Enables return button for resizable textfield
  func multilineSubmitEnabled(
    for text: Binding<String>,
    submitLabel: SubmitLabel = .return
  ) -> some View {
    self.modifier(
      MultilineSubmitViewModifier(
        text: text,
        submitLabel: submitLabel,
        onSubmit: {}
      )
    )
  }
}

extension Float {
  var clean: String {
    return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
  }
}

extension Double {
  var clean: String {
    return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
  }
}
