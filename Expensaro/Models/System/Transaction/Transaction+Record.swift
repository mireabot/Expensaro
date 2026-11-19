//
//  Transaction+Record.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

extension Transaction: ActiveRecord {
  static let refillCategoryName = "Added funds"
  static let dailyType = "Daily transaction"

  var isRefill: Bool {
    categoryName == Self.refillCategoryName
  }

  static var thisMonth: FetchDescriptor<Transaction> {
    let start = Date.startOfCurrentMonth
    return FetchDescriptor(predicate: #Predicate { $0.date >= start }, sortBy: [SortDescriptor(\.date)])
  }

  static var lastMonth: FetchDescriptor<Transaction> {
    let (start, end) = Source.Functions.getPastMonthDates()
    return FetchDescriptor(predicate: #Predicate { $0.date >= start && $0.date <= end })
  }

  static func inCategoryThisMonth(_ categoryName: String) -> FetchDescriptor<Transaction> {
    let start = Date.startOfCurrentMonth
    return FetchDescriptor(
      predicate: #Predicate { $0.date >= start && $0.categoryName == categoryName },
      sortBy: [SortDescriptor(\.amount, order: .reverse)]
    )
  }

  static var dailyThisWeek: FetchDescriptor<Transaction> {
    let calendar = Calendar.current
    guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)),
          let end = calendar.date(byAdding: .day, value: 6, to: start) else {
      fatalError("Unable to calculate the start and end of the week")
    }
    let dailyType = Self.dailyType
    return FetchDescriptor(predicate: #Predicate { $0.date >= start && $0.date <= end && $0.type == dailyType })
  }

  static func deposit(_ amount: Double) -> Transaction {
    Source.Factory.createTransaction(name: "Budget deposit", date: .now, category: (refillCategoryName, "💵", .other), amount: amount, type: "Refill", note: "")
  }

  @MainActor
  func spend(from budget: Budget) throws {
    budget.amount -= amount
    try insert()
  }

  @MainActor
  func changeAmount(to newAmount: Double, in budget: Budget) throws {
    budget.amount += amount - newAmount
    amount = newAmount
    try save()
  }

  /// Deletes the transaction and gives its amount back to the budget, or takes it back for a deposit
  @MainActor
  func delete(restoring budget: Budget) throws {
    budget.amount += isRefill ? -amount : amount
    try delete()
  }
}

extension Array where Element == Transaction {
  var spendings: [Transaction] { filter { !$0.isRefill } }
  var refills: [Transaction] { filter(\.isRefill) }
  var totalAmount: Double { reduce(0) { $0 + $1.amount } }

  var averageAmount: Double {
    isEmpty ? 0 : totalAmount / Double(count)
  }

  /// Totals per weekday, Sunday first, with every weekday present
  var weekdayTotals: [CombinedDailyTransactions] {
    let order = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "en_US")
    let totals = Dictionary(grouping: self) { formatter.string(from: $0.date) }
      .mapValues(\.totalAmount)
    return order.map { CombinedDailyTransactions(weekday: $0, totalAmount: totals[$0] ?? 0) }
  }
}

struct CombinedDailyTransactions: Identifiable {
  var id = UUID()
  let weekday: String
  let totalAmount: Double
}
