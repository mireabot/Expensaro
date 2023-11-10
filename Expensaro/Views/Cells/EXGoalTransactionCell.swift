//
//  EXGoalTransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/19/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXGoalTransactionCell: View {
  let goalTransaction: GoalTransaction
  var body: some View {
    HStack(alignment: .center) {
      Image(Source.Strings.Categories.Images.income)
        .foregroundColor(.primaryGreen)
        .padding(8)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      VStack(alignment: .leading, spacing: -3) {
        Text("Goal contribution")
          .font(.mukta(.medium, size: 15))
          .foregroundColor(.black)
        Text("\(Source.Functions.showString(from: goalTransaction.date))")
          .font(.mukta(.regular, size: 13))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: -3) {
        Text("$\(goalTransaction.amount.withDecimals)")
          .font(.mukta(.medium, size: 15))
          .foregroundColor(.black)
      }
    }
    .background(.white)
  }
}
