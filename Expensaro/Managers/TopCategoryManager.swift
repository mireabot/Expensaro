//
//  TopCategoryManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/28/23.
//

import SwiftUI
import RealmSwift

final class TopCategoryManager: ObservableObject {
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@ AND categoryName != %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg, "Added funds")) var transactions
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@ AND categoryName == %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg, "Added funds")) var refills
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  
  @Published var topCategory: (String, Double, Int) = ("", 0.0, 0)
  @Published var otherCategories: [(String, Double)] = []
  
  @Published var combinedBudget: Double = 0.0
  
  var topCategoryCut: Double {
    return (topCategory.1 / combinedBudget) * 100
  }
  
  init() {
    groupAndFindMaxAmountCategory()
    calculateBudget()
  }
  
  /// Function groups all fetched transactions by category name and calculated total amount spent
  func groupAndFindMaxAmountCategory() {
    var categoryTotals: [String: (Double, Int)] = [:]
    
    if transactions.count < 15 {
      groupAndFindMaxAmountCategoryDemo()
      return
    }
    
    // Group transactions by category and calculate total amount and count for each category
    for transaction in transactions {
      let category = transaction.categoryName
      let currentTotal = categoryTotals[category, default: (0.0, 0)]
      categoryTotals[category] = (currentTotal.0 + transaction.amount, currentTotal.1 + 1)
    }
    
    // Find the category with the highest total amount
    if let maxCategory = categoryTotals.max(by: { $0.value.0 < $1.value.0 }) {
      topCategory.0 = maxCategory.key
      topCategory.1 = maxCategory.value.0
      topCategory.2 = maxCategory.value.1
    }
    updateOtherCategories()
  }
  
  /// Function calculates combined budget for previous month (initial amount + refills)
  private func calculateBudget() {
    var total = 0.0
    if refills.isEmpty {
      total = 0.0
    }
    for refillData in refills {
      total += refillData.amount
    }
    combinedBudget = (budget.first?.initialAmount ?? 0.0) + total
  }
  
  /// Function calculates amount spent for other categories than top
  private func updateOtherCategories() {
    var otherCategoriesTotals: [(String, Double)] = []
    
    if topCategory.0.isEmpty {
      return
    }
    
    // Group transactions by category and calculate total amount and count for each category
    for transaction in transactions {
      let category = transaction.categoryName
      if category != topCategory.0 {
        let currentTotal = otherCategoriesTotals.first(where: { $0.0 == category }) ?? ("", 0.0)
        otherCategoriesTotals.removeAll(where: { $0.0 == category })
        otherCategoriesTotals.append((category, currentTotal.1 + transaction.amount))
      }
    }
    
    // Sort the otherCategoriesTotals by total amount in descending order
    otherCategoriesTotals.sort { $0.1 > $1.1 }
    
    otherCategories = otherCategoriesTotals
  }
  
  /// Function groups demo transactions by category name and calculated total amount spent
  private func groupAndFindMaxAmountCategoryDemo() {
    var categoryTotals: [String: (Double, Int)] = [:]
    
    // Group transactions by category and calculate total amount and count for each category
    for transaction in Source.DefaultData.sampleTransactions {
      let category = transaction.categoryName
      let currentTotal = categoryTotals[category, default: (0.0, 0)]
      categoryTotals[category] = (currentTotal.0 + transaction.amount, currentTotal.1 + 1)
    }
    
    // Find the category with the highest total amount
    if let maxCategory = categoryTotals.max(by: { $0.value.0 < $1.value.0 }) {
      topCategory.0 = maxCategory.key
      topCategory.1 = maxCategory.value.0
      topCategory.2 = maxCategory.value.1
    }
    combinedBudget = 2780
    updateOtherCategoriesDemo()
  }
  
  /// Function calculates amount spent for other categories than top in demo transactions
  private func updateOtherCategoriesDemo() {
    var otherCategoriesTotals: [(String, Double)] = []
    
    if topCategory.0.isEmpty {
      return
    }
    
    // Group transactions by category and calculate total amount and count for each category
    for transaction in Source.DefaultData.sampleTransactions {
      let category = transaction.categoryName
      if category != topCategory.0 {
        let currentTotal = otherCategoriesTotals.first(where: { $0.0 == category }) ?? ("", 0.0)
        otherCategoriesTotals.removeAll(where: { $0.0 == category })
        otherCategoriesTotals.append((category, currentTotal.1 + transaction.amount))
      }
    }
    
    // Sort the otherCategoriesTotals by total amount in descending order
    otherCategoriesTotals.sort { $0.1 > $1.1 }
    
    otherCategories = otherCategoriesTotals
  }
}
