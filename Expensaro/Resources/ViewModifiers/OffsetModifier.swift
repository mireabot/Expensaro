//
//  OffsetModifier.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/20/23.
//

import SwiftUI

struct OffsetModifier: ViewModifier {
  @Binding var offset: CGFloat
  func body(content: Content) -> some View {
    content
      .overlay(
        GeometryReader { proxy -> Color in
          let minY = proxy.frame(in: .named("SCROLL")).minY
          DispatchQueue.main.async {
            self.offset = minY
          }
          return Color.clear
        }
        ,alignment: .top
      )
  }
}
