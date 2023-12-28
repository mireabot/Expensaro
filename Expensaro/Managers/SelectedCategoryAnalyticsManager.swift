//
//  SelectedCategoryAnalyticsManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/28/23.
//

import SwiftUI
import RealmSwift

final class SelectedCategoryAnalyticsManager: ObservableObject {
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg), sortDescriptor: SortDescriptor(keyPath: \Transaction.amount, ascending: false)) var transactions
  var selectedCategory: String = ""
  
  @Published var isLocked: Bool = true
  @Published var averageSpent: Double = 0.0
  @Published var transactionsList: [Transaction] = []
  
  init(selectedCategory: String) {
    self.selectedCategory = selectedCategory
    calculateAverage()
  }
  
  private func calculateAverage() {
    let convertedArray = transactions.toArray()
    transactionsList = convertedArray.filter({$0.categoryName == self.selectedCategory })
    if transactionsList.isEmpty || transactionsList.count < 5 {
      isLocked = true
      return
    }
    let totalAmount = transactionsList.reduce(0.0) {$0 + $1.amount}
    averageSpent = totalAmount / Double(transactionsList.count)
    self.isLocked = false
  }
}
