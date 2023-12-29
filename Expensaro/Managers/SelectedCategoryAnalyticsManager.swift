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
  let demoTransactions: [Transaction] = [
    Source.Realm.createTransaction(name: "Dinner and Show", date: .now, category: ("","",""), amount: 120, type: "", note: ""),
    Source.Realm.createTransaction(name: "Concert Extravaganza", date: .now, category: ("","",""), amount: 80, type: "", note: ""),
    Source.Realm.createTransaction(name: "Amusement Park", date: .now, category: ("","",""), amount: 75, type: "", note: ""),
    Source.Realm.createTransaction(name: "Movie Night", date: .now, category: ("","",""), amount: 45, type: "", note: ""),
    Source.Realm.createTransaction(name: "Gaming Galore", date: .now, category: ("","",""), amount: 60, type: "", note: ""),
    Source.Realm.createTransaction(name: "Escape Room", date: .now, category: ("","",""), amount: 30, type: "", note: ""),
  ]
  var selectedCategory: String = ""
  
  @Published var isLocked: Bool = true
  @Published var averageSpent: Double = 0.0
  @Published var transactionsList: [Transaction] = []
  
  init(selectedCategory: String) {
    self.selectedCategory = selectedCategory
  }
  
  func calculateAverage() {
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
  
  func calculateAverageDemo() {
    let totalAmount = demoTransactions.reduce(0.0) {$0 + $1.amount}
    averageSpent = totalAmount / Double(demoTransactions.count)
  }
}
