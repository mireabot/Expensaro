//
//  EXChartBar.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/14/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXChartBar: View {
  var value: Double
  var maxValue: Int
  var height: CGFloat
  var text: String?
  var isPlain: Bool?
  var color: Color?
  
  private var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
  private var maxWidth: CGFloat { screenWidth - 32 }
  
  private var insetWidth: CGFloat {
    return CGFloat((value * maxWidth) / CGFloat(maxValue))
  }
  private var percentage: Double {
    return (value / Double(maxValue)) * 100
  }
  var body: some View {
    ZStack(alignment: .leading) {
      Rectangle()
        .fill(Color.backgroundGrey)
        .frame(width: self.maxWidth, height: height)
        .cornerRadius(12)
      Rectangle()
        .fill(color ?? Color.primaryGreen)
        .frame(width: self.insetWidth >= self.maxWidth ? self.maxWidth : self.insetWidth, height: height)
        .cornerRadius(12)
      
      VStack(alignment: .leading, spacing: 3) {
        if isPlain != nil {
          Text(text ?? "")
            .font(.headlineRegular)
        }
        else {
          Text("\(percentage.clean)%")
            .font(.calloutBold)
          Text(text ?? "")
            .font(.footnoteRegular)
        }
      }
      .foregroundColor(.white)
      .padding(.leading, 12)
    }
  }
}

