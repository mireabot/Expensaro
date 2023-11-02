//
//  EXRecurringPaymentRenewCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXRecurringPaymentRenewCell: View {
  var payment: RecurringTransaction
  var body: some View {
    VStack(alignment: .leading, spacing: 5, content: {
      Image(payment.categoryIcon)
        .foregroundColor(.primaryGreen)
      Text(payment.name)
        .font(.mukta(.semibold, size: 20))
      HStack(alignment: .center, spacing: 15, content: {
        smallInfoView(title: "Next payment date", text: Source.Functions.showString(from: payment.dueDate))
        smallInfoView(title: "Amount to pay", text: "$\(payment.amount.clean)")
        smallInfoView(title: "Schedule", text: payment.schedule.title)
      })
    })
    .padding(12)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}

#Preview {
  EXRecurringPaymentRenewCell(payment: DefaultRecurringTransactions.transaction2)
}

// MARK: - Helper Views
extension EXRecurringPaymentRenewCell {
  @ViewBuilder
  func smallInfoView(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: -3) {
      Text(title)
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.mukta(.regular, size: 15))
    }
  }
}
