//
//  EXRecurringTransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit
import Shimmer

struct EXRecurringTransactionCell: View {
  var payment: RecurringTransaction
  @AppStorage("currencySign") private var currencySign = "USD"
  var body: some View {
    VStack(alignment: .leading, spacing: 5, content: {
      Text(payment.categoryIcon)
        .foregroundColor(.primaryGreen)
      Text(payment.name)
        .font(.system(.headline, weight: .semibold))
        .multilineTextAlignment(.leading)
        .lineLimit(1)
      Text(payment.amount.formattedAsCurrency(with: currencySign))
        .font(.system(.headline, weight: .semibold))
      
      smallInfoView(title: "Due \(Source.Functions.showString(from: payment.dueDate))", text: daysLeftString(for: payment.daysLeftUntilDueDate))
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
      EXRecurringTransactionCell(payment: Source.DefaultData.sampleRecurringPayments[0])
      EXRecurringTransactionCell(payment: Source.DefaultData.sampleRecurringPayments[1])
    }
    .padding([.leading,.trailing], 16)
  }
}

// MARK: - Helper Views
extension EXRecurringTransactionCell {
  @ViewBuilder
  func smallInfoView(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(title)
        .font(.system(.footnote, weight: .regular))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.system(.subheadline, weight: .semibold))
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

struct EXRecurringTransactionCellLoading: View {
  var body: some View {
    HStack {
      EXRecurringTransactionCell(payment: Source.DefaultData.sampleRecurringPayments[0]).redacted(reason: .placeholder).shimmering()
      EXRecurringTransactionCell(payment: Source.DefaultData.sampleRecurringPayments[0]).redacted(reason: .placeholder).shimmering()
    }
  }
}
