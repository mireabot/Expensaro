//
//  MonthRecapService.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/30/23.
//

import SwiftUI
import Charts
import ExpensaroUIKit
import RealmSwift

final class MonthRecapService: ObservableObject {
  @Published var budgetData: (Double, Double, Double) = (0.0, 0.0, 0.0)
  @Published var goalTotalContribution: Double = 0.0
  @Published var goalContributionBreakdown: [GoalSummary] = []
  @Published var groupedTransactions: [GroupedTransactionsBySection] = []
  @Published var budgetSet: [BudgetsDataSet] = []
  @Published var isLocked: Bool = true
  
  var recapMonth: String {
    Source.Functions.currentMonth(date: Source.Functions.getPastMonthDates().0)
  }
  
  init() {
    calculateBudget()
    convertBudgetDatatoSet()
  }
  
  /// Function groups transactions' categories by global sections
  /// - Parameter array: Array of fetched transactions
  private func groupSections(with array: [Transaction]) {
    var groupedTransactions: [CategoriesSection: [Transaction]] {
      Dictionary(grouping: array) { transaction in
        return transaction.categorySection
      }
    }
    self.groupedTransactions = groupedTransactions.map { section, transactions in
      GroupedTransactionsBySection(transactions: transactions, section: section)
    }
  }
  
  /// Function calculates combined budget for previous month
  func calculateBudget() {
    let realm = try! Realm()
    let startDate = Source.Functions.getPastMonthDates().0
    let endDate = Source.Functions.getPastMonthDates().1
    let predicate = NSPredicate(format: "dateCreated >= %@ AND dateCreated <= %@", startDate as NSDate, endDate as NSDate)
    let addedFundsPredicate = NSPredicate(format: "date >= %@ AND date <= %@ AND categoryName == %@", startDate as NSDate, endDate as NSDate, "Added funds")
    let pastMonthBudget = realm.objects(Budget.self).filter(predicate)
    
    // If budget exists - populate service data with related data
    if let budget = pastMonthBudget.first, !pastMonthBudget.isEmpty {
      isLocked = false
      budgetData.0 = budget.initialAmount
      let pastAddedFunds = realm.objects(Transaction.self).filter(addedFundsPredicate)
      budgetData.1 = pastAddedFunds.toArray().reduce(0) { $0 + $1.amount }
      fetchTransactions()
      calculateGoals()
    } else {
      print("Past budget doesn't exist -> show demo data")
      isLocked = true
      budgetData.0 = 2000
      budgetData.1 = 780
      budgetData.2 = 1600
      goalTotalContribution = 2450
      groupSections(with: Source.DefaultData.sampleTransactions)
    }
  }
  
  /// Function converts budget's data to types breakdown
  private func convertBudgetDatatoSet() {
    budgetSet = [
      BudgetsDataSet(amount: budgetData.0, name: "Initial budget", tag: "Budget", color: Color(red: 0.471, green: 0.718, blue: 0.518)),
      BudgetsDataSet(amount: budgetData.1, name: "Added funds", tag: "Budget", color: Color(red: 0.447, green: 0.773, blue: 0.808)),
      BudgetsDataSet(amount: budgetData.2, name: "Total spent", tag: "Expenses", color: Color(red: 0.851, green: 0.408, blue: 0.396))
    ]
  }
  
  /// Function calculates goals' contributions and group by goal name and calculates total amount saved
  func calculateGoals() {
    let realm = try! Realm()
    let startDate = Source.Functions.getPastMonthDates().0
    let endDate = Source.Functions.getPastMonthDates().1
    let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
    
    let goalContributions = realm.objects(GoalTransaction.self).filter(predicate)
    
    // Group transactions by goal and calculate total amount per goal
    var totalsByGoal = [Goal: Double]()
    goalContributions.forEach { transaction in
      if let goal = transaction.goal.first {
        totalsByGoal[goal, default: 0] += transaction.amount
      }
    }
    
    goalContributionBreakdown = totalsByGoal.map { goal, totalAmount in
      GoalSummary(name: goal.name, totalAmount: totalAmount)
    }
    
    goalTotalContribution = goalContributions.toArray().reduce(0) {$0 + $1.amount }
  }
  
  /// Function fetches transactions which are not refills
  func fetchTransactions() {
    let realm = try! Realm()
    let startDate = Source.Functions.getPastMonthDates().0
    let endDate = Source.Functions.getPastMonthDates().1
    let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND categoryName != %@", startDate as NSDate, endDate as NSDate, "Added funds")
    let pastMonthTransactions = realm.objects(Transaction.self).filter(predicate)
    
    if pastMonthTransactions.isEmpty {
      print("No transactions made")
    }
    else {
      budgetData.2 = pastMonthTransactions.toArray().reduce(0) {$0 + $1.amount }
      groupSections(with: pastMonthTransactions.toArray())
    }
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
