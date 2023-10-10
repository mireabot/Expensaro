//
//  Transaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import Foundation
import SwiftUI
import ExpensaroUIKit
import CoreData

struct TransactionData: Identifiable {
  var id = UUID().uuidString
  var name: String
  var amount: Float
  var type: String
  var date: Date
  var category: (Image, String)
  
  static var sampleTransactions: [TransactionData] = [
    TransactionData(name: "Amazon delivery", amount: 31.75, type: "Credit", date: .now, category: (Image(Source.Strings.Categories.Images.delivery), "Delivery")),
    TransactionData(name: "Patagonia vest", amount: 129.00, type: "Credit", date: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
    TransactionData(name: "iPhone 15 Pro", amount: 999.00, type: "Debit", date: .now, category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
    TransactionData(name: "Late dinner", amount: 4.89, type: "Debit", date: .now, category: (Image(Source.Strings.Categories.Images.goingOut), "Going out")),
    TransactionData(name: "Electronics Purchase", amount: 499.99, type: "Debit", date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
    TransactionData(name: "Grocery Shopping", amount: 85.50, type: "Debit", date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
    TransactionData(name: "Gasoline Purchase", amount: 45.80, type: "Debit", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.shopping), "Shopping")),
  ]
}
