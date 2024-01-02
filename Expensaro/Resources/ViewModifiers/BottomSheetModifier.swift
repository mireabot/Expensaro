//
//  BottomSheetModifier.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI

struct GetHeightModifier: ViewModifier {
  @Binding var height: CGFloat
  
  func body(content: Content) -> some View {
    content.background(
      GeometryReader { geo -> Color in
        DispatchQueue.main.async {
          height = geo.size.height
        }
        return Color.clear
      }
    )
  }
}
