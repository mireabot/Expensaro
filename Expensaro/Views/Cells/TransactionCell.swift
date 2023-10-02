//
//  TransactionCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct TransactionCell: View {
  var icon: Image
  var name: String
  var date: Date
  var amount: Float
  var type: String
  
  init(icon: Image, name: String, date: Date, amount: Float, type: String) {
    self.icon = icon
    self.name = name
    self.date = date
    self.amount = amount
    self.type = type
  }
  
  var body: some View {
    HStack(alignment: .center) {
      icon
        .foregroundColor(.primaryGreen)
        .padding(8)
        .background(Color.backgroundGrey)
        .cornerRadius(16)
      VStack(alignment: .leading, spacing: -3) {
        Text(name)
          .font(.mukta(.medium, size: 15))
        Text("\(Source.Functions.showString(from: date))")
          .font(.mukta(.regular, size: 13))
          .foregroundColor(.darkGrey)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: -3) {
        Text("$\(amount.clean)")
          .font(.mukta(.medium, size: 15))
        if !type.isEmpty {
          Text(type)
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
      TransactionCell(icon: Image(Source.Strings.Categories.Images.car), name: "Gas station", date: .now, amount: 15.78, type: "Credit")
      TransactionCell(icon: Image(Source.Strings.Categories.Images.groceries), name: "Groceries", date: .now, amount: 50.25, type: "Debit")
      TransactionCell(icon: Image(Source.Strings.Categories.Images.subscriptions), name: "Monthly Subscription", date: .now, amount: 9.99, type: "Debit")
    }
    .applyMargins()
  }
}
