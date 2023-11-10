//
//  ScrollView+Extensions.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/9/23.
//

import SwiftUI
import SwiftUIIntrospect

extension ScrollView {
  /// Applies bounce parameter for SrollView
  func applyBounce() -> some View {
    self.introspect(.scrollView, on: .iOS(.v16,.v17)) { scrollView in
      scrollView.bounces = false
    }
  }
}
