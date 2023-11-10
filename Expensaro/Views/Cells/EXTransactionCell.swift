//
//  TransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXTransactionCell: View {
  var transaction: Transaction
  var body: some View {
    HStack(alignment: .center) {
      Image(transaction.categoryIcon)
        .foregroundColor(.primaryGreen)
        .padding(8)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      VStack(alignment: .leading, spacing: -3) {
        Text(transaction.name)
          .font(.mukta(.medium, size: 15))
        Text("\(Source.Functions.showString(from: transaction.date))")
          .font(.mukta(.regular, size: 13))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: -3) {
        if transaction.type == "Refill" {
          Text("+$\(transaction.amount.withDecimals)")
            .font(.mukta(.medium, size: 15))
            .foregroundStyle(Color.green)
        } else {
          Text("$\(transaction.amount.withDecimals)")
            .font(.mukta(.medium, size: 15))
        }
        if !transaction.type.isEmpty {
          Text(transaction.type)
            .font(.mukta(.medium, size: 13))
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
      EXTransactionCell(transaction: DefaultTransactions.defaultTransactions[0])
    }
    .applyMargins()
  }
}
