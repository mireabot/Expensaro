//
//  EXCircleProgressView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/13/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXCircleProgressView: View {
  let progress: CGFloat
  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 5)
        .opacity(0.1)
        .foregroundColor(Color(uiColor: .systemGray2))
      
      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        .foregroundColor(.primaryGreen)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress)
      
      Text("\(String(format: "%.0f", progress * 100))%")
        .font(.title3Bold)
    }
  }
}
