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
  var text: String?
  var maxValue: Int
  private var screenWidth: CGFloat {UIScreen.main.bounds.size.width }
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
        .frame(width: self.maxWidth, height: 55)
        .cornerRadius(12)
      Rectangle()
        .fill(Color.primaryGreen)
        .frame(width: self.insetWidth, height: 55)
        .cornerRadius(12)
      
      VStack(alignment: .leading, spacing: 3) {
        Text("\(percentage.clean)%")
          .font(.calloutBold)
        Text(text ?? "")
          .font(.footnoteRegular)
      }
      .foregroundColor(.white)
      .padding(.leading, 12)
    }
  }
}

