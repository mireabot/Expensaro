//
//  Transaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

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

// MARK: Default transactions for previews
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
