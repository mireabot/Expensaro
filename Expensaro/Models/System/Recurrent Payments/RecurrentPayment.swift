//
//  RecurrentPayment.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import SwiftData

extension ExpensaroSchemaV1 {
  @Model
  final class RecurringTransaction {
    // LocalNotificationsManager builds reminder identifiers from this string
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String = ""
    var amount: Double = 0
    var dueDate: Date = Date()
    var type: String = ""
    var categoryName: String = "Other"
    var categoryIcon: String = "📔"
    var scheduleRaw: String = RecurringSchedule.everyWeek.rawValue
    var reminderTypeRaw: String = ReminderType.day.rawValue
    var note: String = ""
    var isReminder: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \PaymentContributions.payment)
    var contributions: [PaymentContributions] = []

    init() {}

    var schedule: RecurringSchedule {
      get { RecurringSchedule(rawValue: scheduleRaw) ?? .everyWeek }
      set { scheduleRaw = newValue.rawValue }
    }

    var reminderType: ReminderType {
      get { ReminderType(rawValue: reminderTypeRaw) ?? .day }
      set { reminderTypeRaw = newValue.rawValue }
    }
  }

  @Model
  final class PaymentContributions {
    @Attribute(.unique) var id: String = UUID().uuidString
    var amount: Double = 0
    var date: Date = Date()
    var payment: RecurringTransaction?

    init() {}
  }
}

enum RecurringSchedule: String, CaseIterable {
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

enum ReminderType: String, CaseIterable {
  case day
  case week
  
  var title: String {
    switch self {
    case .day:
      return "1 day prior"
    case .week:
      return "7 days prior"
    }
  }
  
  var delay: Int {
    switch self {
    case .day:
      return -1
    case .week:
      return -7
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
    return Calendar.current.isDate(dueDate, inSameDayAs: Date()) || dueDate < Date()
  }
}

// MARK: Struct to combine recurring payments by due date
struct RecurrentPaymentData: Identifiable{
  var id = UUID().uuidString
  var payments: [RecurringTransaction]
  var paymentDueDate: Date
}
