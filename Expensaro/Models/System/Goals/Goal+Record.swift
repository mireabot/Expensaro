//
//  Goal+Record.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

extension Goal: ActiveRecord {
  static var byDueDate: FetchDescriptor<Goal> {
    FetchDescriptor(sortBy: [SortDescriptor(\.dueDate)])
  }

  var transactionsNewestFirst: [GoalTransaction] {
    transactions.sorted { $0.date > $1.date }
  }

  @MainActor
  func create(finalAmount: Double) throws {
    self.finalAmount = finalAmount
    dateCreated = .now
    try insert()
  }

  /// Adds the contribution's amount to a stored goal and links the contribution to it
  @MainActor
  func contribute(_ contribution: GoalTransaction) throws {
    guard let context = modelContext else { return }
    currentAmount += contribution.amount
    // Insert first, then link from the child side only
    context.insert(contribution)
    contribution.goal = self
    try context.save()
  }
}

extension GoalTransaction: ActiveRecord {
  static var lastMonth: FetchDescriptor<GoalTransaction> {
    let (start, end) = Source.Functions.getPastMonthDates()
    return FetchDescriptor(predicate: #Predicate { $0.date >= start && $0.date <= end })
  }
}
