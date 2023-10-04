//
//  TransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct TransactionCell: View {
  var transaction: Transaction
  
  init(transaction: Transaction) {
    self.transaction = transaction
  }
  
  var body: some View {
    HStack(alignment: .center) {
      transaction.category.0
        .foregroundColor(.primaryGreen)
        .padding(8)
        .background(Color.backgroundGrey)
        .cornerRadius(16)
      VStack(alignment: .leading, spacing: -3) {
        Text(transaction.name)
          .font(.mukta(.medium, size: 15))
        Text("\(Source.Functions.showString(from: transaction.date))")
          .font(.mukta(.regular, size: 13))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: -3) {
        Text("$\(transaction.amount.clean)")
          .font(.mukta(.medium, size: 15))
        if !transaction.type.isEmpty {
          Text(transaction.type)
            .font(.mukta(.medium, size: 13))
            .foregroundColor(.primaryGreen)
        }
      }
    }
  }
}

struct TransactionCell_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TransactionCell(transaction: Transaction.sampleTransactions[0])
    }
    .applyMargins()
  }
}
