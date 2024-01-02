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
  var radius: CGFloat?
  var margin: CGFloat?
  
  private var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
  private var maxWidth: CGFloat { screenWidth - (margin ?? 32) }
  
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
        .cornerRadius(radius ?? 12)
      Rectangle()
        .fill(color ?? Color.primaryGreen)
        .frame(width: self.insetWidth >= self.maxWidth ? self.maxWidth : self.insetWidth, height: height)
        .cornerRadius(radius ?? 12)
      
      VStack(alignment: .leading, spacing: 3) {
        if isPlain != nil {
          Text("\(percentage.clean)%")
            .font(.calloutBold)
          if let text = text {
            Text(text)
              .font(.footnoteRegular)
          }
        }
      }
      .foregroundColor(.white)
      .padding(.leading, 12)
    }
  }
}

struct EXBar: View {
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

#Preview(body: {
  EXBaseCard {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 5) {
        Text("Initial budget")
          .font(.footnoteSemibold)
          .foregroundColor(.darkGrey)
        HStack {
          Rectangle()
            .fill(Color.primaryGreen)
            .frame(width: 2000 * 0.08, height: 30)
            .cornerRadius(5)
          Text("$\(2000)")
            .font(.subheadlineBold)
        }
      }
      VStack(alignment: .leading, spacing: 5) {
        Text("Added funds")
          .font(.footnoteSemibold)
          .foregroundColor(.darkGrey)
        HStack {
          Rectangle()
            .fill(.green.opacity(0.8))
            .frame(width: 780 * 0.08, height: 30)
            .cornerRadius(5)
          Text("$\(780)")
            .font(.subheadlineBold)
        }
      }
      VStack(alignment: .leading, spacing: 5) {
        Text("Total spent")
          .font(.footnoteSemibold)
          .foregroundColor(.darkGrey)
        HStack {
          Rectangle()
            .fill(Color(uiColor: .quaternarySystemFill))
            .frame(width: 1600 * 0.08, height: 30)
            .cornerRadius(5)
          Text("$\(1600)")
            .font(.subheadlineBold)
        }
      }
    }
    .padding(4)
    .frame(maxWidth: .infinity, alignment: .leading)
  }.applyMargins()
})
