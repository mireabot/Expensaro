//
//  RecurrentPaymentCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXRecurringTransactionCell: View {
  var transaction: RecurringTransaction
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(transaction.name)
        .font(.mukta(.medium, size: 15))
        .multilineTextAlignment(.leading)
      HStack(alignment: .center, spacing: 1) {
        Text("$\(transaction.amount.clean)")
          .font(.mukta(.medium, size: 13))
          .lineLimit(3)
        Text("/ \(Int(transaction.daysLeftUntilDueDate)) days left")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 11))
          .lineLimit(3)
      }
      ProgressView(value: transaction.progress)
        .tint(.primaryGreen)
    }
    .padding(10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}


struct RecurrentPaymentCell_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      EXRecurringTransactionCell(transaction: DefaultRecurringTransactions.sampleRecurringTransactions[0])
      EXRecurringTransactionCell(transaction: DefaultRecurringTransactions.sampleRecurringTransactions[1])
    }
    .padding([.leading,.trailing], 16)
  }
}
