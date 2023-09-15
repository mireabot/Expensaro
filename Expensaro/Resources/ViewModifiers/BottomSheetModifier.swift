//
//  BottomSheetModifier.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat?
  
  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    guard let nextValue = nextValue() else { return }
    value = nextValue
  }
}

struct ReadHeightModifier: ViewModifier {
  private var sizeView: some View {
    GeometryReader { geometry in
      Color.clear.preference(key: HeightPreferenceKey.self, value: geometry.size.height)
    }
  }
  func body(content: Content) -> some View {
    content.background(sizeView)
  }
}
