//
//  RecurrentPayment.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import RealmSwift

struct RecurrentPayment: Identifiable {
  var id = UUID().uuidString
  var name: String
  var amount: Float
  var currentValue: CGFloat
  var maxValue: CGFloat
  var dueDate: Date
  var category: (Image, String)
  var periodicity: String?
  var isReminderTurned: Bool?
  
  static let recurrentPayments: [RecurrentPayment] = [
    RecurrentPayment(name: "Netflix", amount: 12.99, currentValue: 15, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Amazon Prime", amount: 9.99, currentValue: 5, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription"), periodicity: "Every week", isReminderTurned: true),
    RecurrentPayment(name: "Hulu", amount: 7.99, currentValue: 25, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Apple Music", amount: 9.99, currentValue: 20, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Disney+", amount: 7.99, currentValue: 12, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Gym Membership", amount: 29.99, currentValue: 2, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Electricity Bill", amount: 50.0, currentValue: 28, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Water Bill", amount: 20.0, currentValue: 3, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Internet", amount: 45.0, currentValue: 30, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Cell Phone", amount: 40.0, currentValue: 18, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription"))
  ]
}

struct RecurrentPaymentData: Identifiable{
  var id = UUID().uuidString
  var payments: [RecurrentPayment]
  var paymentDueDate: Date
}

var sampleRecurrentPayments : [RecurrentPaymentData] = [
  RecurrentPaymentData(payments: [
    RecurrentPayment(name: "Netflix", amount: 12.99, currentValue: 15, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Amazon Prime", amount: 9.99, currentValue: 5, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Hulu", amount: 7.99, currentValue: 25, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Apple Music", amount: 9.99, currentValue: 20, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Disney+", amount: 7.99, currentValue: 12, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription"))
  ], paymentDueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
  
  RecurrentPaymentData(payments: [
    RecurrentPayment(name: "Gym Membership", amount: 29.99, currentValue: 2, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Electricity Bill", amount: 50.0, currentValue: 28, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Water Bill", amount: 20.0, currentValue: 3, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Internet", amount: 45.0, currentValue: 30, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription")),
    RecurrentPayment(name: "Cell Phone", amount: 40.0, currentValue: 18, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(), category: (Image(Source.Strings.Categories.Images.subscriptions), "Subscription"))
  ], paymentDueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
]

final class RecurringTransaction: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var amount: Double
  @Persisted var dueDate: Date
  @Persisted var type: String
  @Persisted var categoryName: String = "Other"
  @Persisted var categoryIcon: String = Source.Strings.Categories.Images.other
  @Persisted var isReminder: Bool = false
}

extension RecurringTransaction {
  var daysInCurrentMonth: Int {
    let calendar = Calendar.current
    let range = calendar.range(of: .day, in: .month, for: Date())
    return range?.count ?? 0
  }
  
  var daysLeftUntilDueDate: Int {
    let calendar = Calendar.current
    let currentDate = Date()
    let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
    return components.day ?? 0
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
}

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
    transaction.name = "Gym Membership"
    transaction.amount = 29.99
    transaction.dueDate = Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()
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
