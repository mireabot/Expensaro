//
//  EXRecurringTransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXRecurringTransactionCell: View {
  var transaction: RecurringTransaction
  var body: some View {
    HStack(alignment: .center) {
      Image(transaction.categoryIcon)
        .foregroundColor(.primaryGreen)
        .padding(8)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      VStack(alignment: .leading, spacing: -3) {
        HStack(alignment: .top, spacing: 3) {
          Text(transaction.name)
            .font(.mukta(.medium, size: 15))
          if transaction.isReminder {
            Source.Images.System.reminder
              .resizable()
              .frame(width: 15, height: 15)
              .foregroundColor(.darkGrey)
          }
        }
        Text("Due \(Source.Functions.showString(from: transaction.dueDate))")
          .font(.mukta(.regular, size: 13))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: -3) {
        Text("$\(transaction.amount.clean)")
          .font(.mukta(.medium, size: 15))
        Text("\(Int(transaction.daysLeftUntilDueDate)) days left")
          .font(.mukta(.medium, size: 13))
          .foregroundColor(.primaryGreen)
      }
    }
    .background(.white)
  }
}


struct RecurrentPaymentCell_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      EXRecurringTransactionCell(transaction: DefaultRecurringTransactions.sampleRecurringTransactions[0])
      EXRecurringTransactionCell(transaction: DefaultRecurringTransactions.sampleRecurringTransactions[1])
    }
    .padding([.leading,.trailing], 16)
  }
}
