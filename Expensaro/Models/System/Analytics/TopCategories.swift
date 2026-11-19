//
//  TopCategories.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/14/23.
//

import SwiftUI

struct TopCategories: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

let topCategoriesData: [TopCategories] = [
  TopCategories(name: "Groceries", amount: 800),
  TopCategories(name: "Entertainment", amount: 500),
  TopCategories(name: "Bills", amount: 700),
  TopCategories(name: "Subscriptions", amount: 350)
]

// MARK: Top category for the current month
/// Top spending category from this month's transactions and budget, as queried by the view.
/// Below `minimumSpendings` it shows the demo transactions instead.
struct TopCategorySummary: Hashable {
  static let minimumSpendings = 15
  /// Identity of this snapshot. The figures hold tuples, which can't be Hashable,
  /// so equality is per computed snapshot; that's all a navigation route needs
  private let snapshotID = UUID()

  let spendingsCount: Int
  let topCategory: (name: String, amount: Double, count: Int)
  /// Other categories with their totals, largest first
  let otherCategories: [(String, Double)]
  let combinedBudget: Double

  var isLocked: Bool {
    spendingsCount < Self.minimumSpendings
  }

  var topCategoryCut: Double {
    (topCategory.amount / combinedBudget) * 100
  }

  init(transactions: [Transaction], budget: Budget?) {
    let spendings = transactions.spendings
    spendingsCount = spendings.count
    let shown = spendings.count < Self.minimumSpendings ? Source.DefaultData.sampleTransactions : spendings
    let totals = Dictionary(grouping: shown, by: \.categoryName)
      .mapValues { (amount: $0.totalAmount, count: $0.count) }
    if let top = totals.max(by: { $0.value.amount < $1.value.amount }) {
      topCategory = (top.key, top.value.amount, top.value.count)
      otherCategories = totals
        .filter { $0.key != top.key }
        .map { ($0.key, $0.value.amount) }
        .sorted { $0.1 > $1.1 }
    } else {
      topCategory = ("", 0, 0)
      otherCategories = []
    }
    combinedBudget = (budget?.initialAmount ?? 0) + transactions.refills.totalAmount
  }
}

extension TopCategorySummary {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.snapshotID == rhs.snapshotID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(snapshotID)
  }
}
