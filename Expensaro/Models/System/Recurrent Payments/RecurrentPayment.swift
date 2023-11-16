//
//  RecurrentPayment.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import RealmSwift

final class RecurringTransaction: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var amount: Double
  @Persisted var dueDate: Date
  @Persisted var type: String
  @Persisted var categoryName: String = "Other"
  @Persisted var categoryIcon: String = Source.Strings.Categories.Images.other
  @Persisted var schedule: RecurringSchedule = RecurringSchedule.everyWeek
  @Persisted var note: String = ""
  @Persisted var isReminder: Bool = false
}

enum RecurringSchedule: String, CaseIterable, PersistableEnum {
  case everyWeek
  case everyMonth
  case every3Month
  case everyYear
  
  var title: String {
    switch self {
    case .everyWeek:
      return "Every week"
    case .everyMonth:
      return "Every month"
    case .every3Month:
      return "Every 3 months"
    case .everyYear:
      return "Every year"
    }
  }
}

// MARK: Computed variables for recurring payment
extension RecurringTransaction {
  var daysInCurrentMonth: Int {
    let calendar = Calendar.current
    let range = calendar.range(of: .day, in: .month, for: Source.Functions.localDate(with: .now))
    return range?.count ?? 0
  }
  
  var daysLeftUntilDueDate: Int {
    let calendar = Calendar.current
    let fromDate = calendar.startOfDay(for: Date())
    let toDate = calendar.startOfDay(for: dueDate)
    let numberOfDays = calendar.dateComponents([.day], from: fromDate, to: toDate)
    
    return numberOfDays.day!
  }
  
  var daysPastDueDate: Int {
    let calendar = Calendar.current
    let currentDate = Date()
    if let days = calendar.dateComponents([.day], from: dueDate, to: currentDate).day, days > 0 {
      return days
    }
    return 0
  }
  
  var progress: Double {
    let totalDays = Double(daysInCurrentMonth)
    let remainingDays = Double(daysLeftUntilDueDate)
    return min(1.0, max(0.0, (totalDays - remainingDays) / totalDays))
  }
  
  var isDue: Bool {
    return Calendar.current.isDate(dueDate, inSameDayAs: Date())
  }
}

// MARK: Default recurring transactions for previews
enum DefaultRecurringTransactions {
  static var transaction1: RecurringTransaction {
    let transaction = RecurringTransaction()
    transaction.name = "Netflix"
    transaction.amount = 12.99
    transaction.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    transaction.type = "Debit"
    transaction.categoryName = "Subscription"
    transaction.categoryIcon = Source.Strings.Categories.Images.subscriptions
    transaction.isReminder = false
    return transaction
  }
  
  static var transaction2: RecurringTransaction {
    let transaction = RecurringTransaction()
    transaction.name = "Gym Membership long name"
    transaction.amount = 29.99
    transaction.dueDate = Date()
    transaction.type = "Credit"
    transaction.categoryName = "Subscription"
    transaction.categoryIcon = Source.Strings.Categories.Images.subscriptions
    transaction.isReminder = true
    return transaction
  }
  
  static let sampleRecurringTransactions = [
    transaction1,
    transaction2
  ]
}

// MARK: Struct to combine recurring payments by due date
struct RecurrentPaymentData: Identifiable{
  var id = UUID().uuidString
  var payments: [RecurringTransaction]
  var paymentDueDate: Date
}
