//
//  Transaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import Charts

struct Transaction: Identifiable {
  var id = UUID().uuidString
  var name: String
  var amount: Float
  var type: String
  var date: Date
  var category: (Image, String)
  
  static var sampleTransactions: [Transaction] = [
    Transaction(name: "Amazon delivery", amount: 31.75, type: "Credit", date: .now, category: (Image(Source.Strings.Categories.Images.delivery), "Delivery")),
    Transaction(name: "Patagonia vest", amount: 129.00, type: "Credit", date: Date().addingTimeInterval(60 * 60 * 24 * 60), category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
    Transaction(name: "iPhone 15 Pro", amount: 999.00, type: "Debit", date: .now, category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
    Transaction(name: "Late dinner", amount: 4.89, type: "Debit", date: .now, category: (Image(Source.Strings.Categories.Images.goingOut), "Going out")),
  ]
}
