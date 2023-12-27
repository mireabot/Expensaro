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
  
  /// Runs code only when view appeares
  func onFirstAppear(_ action: @escaping () -> ()) -> some View {
    modifier(FirstAppear(action: action))
  }
  
  /// Specific corner radius
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape( RoundedCorner(radius: radius, corners: corners) )
  }
}

private struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
