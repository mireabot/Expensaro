//
//  EXRecurringTransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXRecurringTransactionCell: View {
  var payment: RecurringTransaction
  var body: some View {
    VStack(alignment: .leading, spacing: 0, content: {
      Image(payment.categoryIcon)
        .foregroundColor(.primaryGreen)
      Text(payment.name)
        .font(.mukta(.semibold, size: 17))
        .multilineTextAlignment(.leading)
        .lineLimit(1)
      Text("$\(payment.amount.withDecimals)")
        .font(.mukta(.semibold, size: 17))
      HStack(alignment: .center, spacing: 15, content: {
        smallInfoView(title: "Due \(Source.Functions.showString(from: payment.dueDate))", text: daysLeftString(for: payment.daysLeftUntilDueDate))
      })
      .padding(.top, 3)
    })
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(Color.backgroundGrey)
    .cornerRadius(16)
  }
}


struct RecurrentPaymentCell_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      EXRecurringTransactionCell(payment: DefaultRecurringTransactions.sampleRecurringTransactions[0])
      EXRecurringTransactionCell(payment: DefaultRecurringTransactions.sampleRecurringTransactions[1])
    }
    .padding([.leading,.trailing], 16)
  }
}

// MARK: - Helper Views
extension EXRecurringTransactionCell {
  @ViewBuilder
  func smallInfoView(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: -3) {
      Text(title)
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.mukta(.medium, size: 15))
        .foregroundColor(.primaryGreen)
    }
  }
  
  func daysLeftString(for days: Int) -> String {
    switch days {
    case -1:
      return "Overdue 1 day"
    case 0:
      return "Today"
    case 1:
      return "1 day left"
    case let negativeDays where negativeDays < 0:
      return "Overdue \(abs(negativeDays)) days"
    default:
      return "\(days) days left"
    }
  }
}
