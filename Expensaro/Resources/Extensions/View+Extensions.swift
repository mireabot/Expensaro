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
}
