//
//  Budget+Record.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

extension Budget: ActiveRecord {
  static var thisMonth: FetchDescriptor<Budget> {
    let start = Date.startOfCurrentMonth
    return FetchDescriptor(predicate: #Predicate { $0.dateCreated >= start })
  }

  static var lastMonth: FetchDescriptor<Budget> {
    let (start, end) = Source.Functions.getPastMonthDates()
    return FetchDescriptor(predicate: #Predicate { $0.dateCreated >= start && $0.dateCreated <= end })
  }

  @MainActor
  func start(with amount: Double) throws {
    self.amount = amount
    initialAmount = amount
    try insert()
  }

  /// Tops up a stored budget and records the deposit as an "Added funds" transaction
  @MainActor
  func addFunds(_ amount: Double) throws {
    guard let context = modelContext else { return }
    self.amount += amount
    try Transaction.deposit(amount).insert(into: context)
  }
}
