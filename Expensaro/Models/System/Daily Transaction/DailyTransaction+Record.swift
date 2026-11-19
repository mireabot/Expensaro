//
//  DailyTransaction+Record.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

extension DailyTransaction: ActiveRecord {
  static var byDateCreated: FetchDescriptor<DailyTransaction> {
    FetchDescriptor(sortBy: [SortDescriptor(\.dateCreated)])
  }

  @MainActor
  func create(amount: Double) throws {
    self.amount = amount
    dateCreated = .now
    try insert()
  }

  /// Records one use of this preset as a transaction. Returns false, and stores nothing,
  /// when the budget cannot cover it.
  @MainActor
  @discardableResult
  func spend(from budget: Budget) throws -> Bool {
    guard amount <= budget.amount else { return false }
    let transaction = Source.Factory.createTransaction(name: name, date: .now, category: (categoryName, categoryIcon, categorySection), amount: amount, type: Transaction.dailyType, note: "")
    try transaction.spend(from: budget)
    return true
  }
}
