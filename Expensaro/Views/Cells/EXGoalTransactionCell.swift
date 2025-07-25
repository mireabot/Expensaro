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
  @AppStorage("currencySign") private var currencySign = "USD"
  var body: some View {
    HStack(alignment: .center) {
      Text("💵")
        .foregroundColor(.primaryGreen)
        .padding(12)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      VStack(alignment: .leading, spacing: 3) {
        Text("Goal contribution")
          .font(.system(.subheadline, weight: .medium))
          .foregroundColor(.black)
        Text("\(Source.Functions.showString(from: goalTransaction.date))")
          .font(.system(.footnote, weight: .regular))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      Text("\(goalTransaction.amount.formattedAsCurrency(with: currencySign))")
        .font(.system(.subheadline, weight: .medium))
        .foregroundColor(.black)
    }
    .background(.white)
  }
}
