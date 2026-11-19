//
//  MonthRecapData.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/24/23.
//

import SwiftUI

// MARK: Sample data for categories breakdown
struct SampleCategoriesBreakdown: Identifiable {
  var id = UUID()
  var categoryName: CategoriesSection
  var amount: Double
  var progressColor: Color
}

var sampleStorageDetails: [SampleCategoriesBreakdown] = [
  SampleCategoriesBreakdown(categoryName: .entertainment, amount: 600, progressColor: Color(red: 0.612, green: 0.22, blue: 0.282)),
  SampleCategoriesBreakdown(categoryName: .food, amount: 100, progressColor: Color(red: 1, green: 0.678, blue: 0.412)),
  SampleCategoriesBreakdown(categoryName: .other, amount: 400, progressColor: Color(red: 0.961, green: 0.902, blue: 0.388)),
  SampleCategoriesBreakdown(categoryName: .transportation, amount: 1000, progressColor: Color(red: 0.278, green: 0.659, blue: 0.741)),
  SampleCategoriesBreakdown(categoryName: .lifestyle, amount: 760, progressColor: Color(red: 0.118, green: 0.22, blue: 0.533))
]


// MARK: Previous month recap
/// Recap of the previous month from the rows the view queried with the `lastMonth` descriptors.
/// Without a budget for that month it shows demo figures and stays locked.
struct MonthRecap {
  /// Initial budget, added funds, total spent, budget left
  private(set) var budgetData: (Double, Double, Double, Double) = (0, 0, 0, 0)
  private(set) var goalTotalContribution: Double = 0
  private(set) var goalContributionBreakdown: [GoalSummary] = []
  private(set) var groupedTransactions: [GroupedTransactionsBySection] = []
  let isLocked: Bool

  var recapMonth: String {
    Source.Functions.currentMonth(date: Source.Functions.getPastMonthDates().0)
  }

  var budgetSet: [BudgetsDataSet] {
    [
      BudgetsDataSet(amount: budgetData.0, name: "Initial budget", tag: "Budget", color: Color(red: 0.471, green: 0.718, blue: 0.518)),
      BudgetsDataSet(amount: budgetData.1, name: "Added funds", tag: "Budget", color: Color(red: 0.447, green: 0.773, blue: 0.808)),
      BudgetsDataSet(amount: budgetData.2, name: "Total spent", tag: "Expenses", color: Color(red: 0.851, green: 0.408, blue: 0.396))
    ]
  }

  init(budgets: [Budget], transactions: [Transaction], goalTransactions: [GoalTransaction]) {
    guard let budget = budgets.first else {
      isLocked = true
      budgetData = (2000, 780, 1600, 450)
      goalTotalContribution = 1600
      groupedTransactions = Self.groupBySection(Source.DefaultData.sampleTransactions)
      goalContributionBreakdown = [GoalSummary(name: "MacBook Pro", totalAmount: 1600)]
      return
    }
    isLocked = false
    let spendings = transactions.spendings
    budgetData = (budget.initialAmount, transactions.refills.totalAmount, spendings.totalAmount, budget.amount)
    groupedTransactions = Self.groupBySection(spendings)

    let totalsByGoal = Dictionary(grouping: goalTransactions.filter { $0.goal != nil }, by: { $0.goal! })
      .mapValues { $0.reduce(0) { $0 + $1.amount } }
    goalContributionBreakdown = totalsByGoal.map { GoalSummary(name: $0.key.name, totalAmount: $0.value) }
    goalTotalContribution = goalTransactions.reduce(0) { $0 + $1.amount }
  }

  private static func groupBySection(_ transactions: [Transaction]) -> [GroupedTransactionsBySection] {
    Dictionary(grouping: transactions, by: \.categorySection)
      .map { GroupedTransactionsBySection(transactions: $0.value, section: $0.key) }
  }
}

// MARK: Struct to combine transactions by category section
struct GroupedTransactionsBySection: Identifiable {
  var id = UUID()
  var transactions: [Transaction]
  var section: CategoriesSection
  
  var totalAmount: Double {
    return transactions.reduce(0) { $0 + $1.amount }
  }
  
  private var groupedTransactionsByCategory: [String: [Transaction]] {
    return Dictionary(grouping: transactions, by: { $0.categoryName })
  }
  
  var totalAmountByCategory: [(String, Double, String)] {
    return groupedTransactionsByCategory.map { categoryName, transactions in
      let totalAmount = transactions.reduce(0) { $0 + $1.amount }
      let categoryIcon = transactions.first?.categoryIcon ?? ""
      return (categoryName, totalAmount, categoryIcon)
    }
  }
}

// MARK: Struct which combines data about budget into plotable set
struct BudgetsDataSet: Identifiable {
  var id = UUID()
  var amount: Double
  var name: String
  var tag: String
  var color: Color
}

// MARK: Struct which combines data about goals contributions into array
struct GoalSummary: Identifiable {
  var id = UUID()
  var name: String
  var totalAmount: Double
}
