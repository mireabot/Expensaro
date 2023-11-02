//
//  FirstAppear.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/1/23.
//

import SwiftUI

struct FirstAppear: ViewModifier {
  let action: () -> ()
  
  // Use this to only fire your block one time
  @State private var hasAppeared = false
  
  func body(content: Content) -> some View {
    // And then, track it here
    content.onAppear {
      guard !hasAppeared else { return }
      hasAppeared = true
      action()
    }
  }
}
