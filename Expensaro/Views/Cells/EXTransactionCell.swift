//
//  TransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit
import Shimmer

struct EXTransactionCell: View {
  var transaction: Transaction
  @AppStorage("currencySign") private var currencySign = "USD"
  var body: some View {
    HStack(alignment: .center) {
      Text(transaction.categoryIcon)
        .foregroundColor(.primaryGreen)
        .padding(12)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      VStack(alignment: .leading, spacing: 3) {
        Text(transaction.name)
          .font(.system(.subheadline, weight: .semibold))
        Text("\(Source.Functions.showString(from: transaction.date))")
          .font(.system(.footnote, weight: .medium))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 3) {
        if transaction.type == "Refill" {
          Text("+\(transaction.amount.formattedAsCurrency(with: currencySign))")
            .font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(Color.green)
        } else {
          Text(transaction.amount.formattedAsCurrency(with: currencySign))
            .font(.system(.subheadline, weight: .medium))
        }
        if !transaction.type.isEmpty {
          Text(transaction.type)
            .font(.system(.footnote, weight: .medium))
            .foregroundColor(.primaryGreen)
        }
      }
    }
    .background(.white)
  }
}

struct TransactionCell_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      EXTransactionCell(transaction: Source.DefaultData.sampleTransactions[0])
      EXTransactionCell(transaction: Source.DefaultData.sampleTransactions[1])
    }
    .applyMargins()
  }
}

struct EXTransactionCellLoading: View {
  var body: some View {
    VStack {
      EXTransactionCell(transaction: Source.DefaultData.sampleTransactions[0]).redacted(reason: .placeholder).shimmering()
      EXTransactionCell(transaction: Source.DefaultData.sampleTransactions[0]).redacted(reason: .placeholder).shimmering()
      EXTransactionCell(transaction: Source.DefaultData.sampleTransactions[0]).redacted(reason: .placeholder).shimmering()
    }
  }
}
