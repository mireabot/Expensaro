//
//  Transaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

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

final class Transaction: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var amount: Double
  @Persisted var type: String
  @Persisted var date: Date
  @Persisted var categoryName: String = "Other"
  @Persisted var categoryIcon: String = Source.Strings.Categories.Images.other
  @Persisted var note: String
}

enum DefaultTransactions {
  static var transaction1: Transaction {
    let transaction = Transaction()
    transaction.name = "Amazon delivery"
    transaction.amount = 31.75
    transaction.type = "Debit"
    transaction.date = Date()
    transaction.categoryName = "Delivery"
    transaction.categoryIcon = Source.Strings.Categories.Images.delivery
    transaction.note = ""
    return transaction
  }
  
  static var transaction2: Transaction {
    let transaction = Transaction()
    transaction.name = "Patagonia vest"
    transaction.amount = 129
    transaction.type = "Credit"
    transaction.date = Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date()
    transaction.categoryName = "Shopping"
    transaction.categoryIcon = Source.Strings.Categories.Images.shopping
    transaction.note = ""
    return transaction
  }
  
  static let defaultTransactions = [
    transaction1,
    transaction2
  ]
}
