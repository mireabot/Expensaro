//
//  DailyTransactionsAnalyticsManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/28/24.
//

import Foundation
import RealmSwift

final class DailyTransactionsAnalyticsManager: ObservableObject {
  @Published var isLocked: Bool = true
  @Published var groupedTransactions: [CombinedDailyTransactions] = []
  
  init() {
    fetchDailyTransactions()
  }
  
  private func fetchDailyTransactions() {
    // Fetch transactions in range of current week, minimum is 4 objects
    guard let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
          let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) else {
      fatalError("Unable to calculate the start and end of the week")
    }
    
    let realm = try! Realm()
    let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND type == %@", startOfWeek as NSDate, endOfWeek as NSDate, "Daily transaction")
    let dailyTransactions = realm.objects(Transaction.self).filter(predicate)
    
    if dailyTransactions.count < 4 {
      isLocked = true
      print("Not enough objects")
      return
    }
    
    self.groupedTransactions = groupFetchedTransactions(transactions: dailyTransactions.toArray())
    isLocked = false
    
    print(groupedTransactions)
  }
  
  private func groupFetchedTransactions(transactions: [Transaction]) -> [CombinedDailyTransactions] {
    // Initialize a dictionary with all weekdays set to 0
    var weekdayTotals: [String: Double] = ["Sun": 0, "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0]
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE" // Format for full weekday name
    dateFormatter.locale = Locale(identifier: "en_US") // Adjust locale as needed
    
    // Sum amounts for each transaction's weekday
    for transaction in transactions {
      let weekday = dateFormatter.string(from: transaction.date)
      weekdayTotals[weekday] = (weekdayTotals[weekday] ?? 0) + transaction.amount
    }
    
    // Convert the totals into AnalyticsTransaction objects
    let analyticsTransactions = weekdayTotals.map { CombinedDailyTransactions(weekday: $0.key, totalAmount: $0.value) }
    
    // Ensure the order of the days if needed
    let sortedAnalyticsTransactions = analyticsTransactions.sorted { (lhs, rhs) -> Bool in
      let order = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
      return order.firstIndex(of: lhs.weekday)! < order.firstIndex(of: rhs.weekday)!
    }
    
    return sortedAnalyticsTransactions
  }
}

struct CombinedDailyTransactions: Identifiable {
  var id = UUID()
  let weekday: String
  let totalAmount: Double
}
