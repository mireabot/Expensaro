//
//  RecurrentPayment+Record.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

extension RecurringTransaction: ActiveRecord {
  static var byDueDate: FetchDescriptor<RecurringTransaction> {
    FetchDescriptor(sortBy: [SortDescriptor(\.dueDate)])
  }

  var nextDueDate: Date {
    let days = switch schedule {
    case .everyWeek: 7
    case .everyMonth: 31
    case .every3Month: 90
    case .everyYear: 365
    }
    return getSampleDate(offset: days, date: dueDate)
  }

  /// Stores a new payment, charges the budget and schedules its reminder if one is set
  @MainActor
  func create(amount: Double, charging budget: Budget) throws {
    self.amount = amount
    budget.amount -= amount
    try insert()
    rescheduleReminder()
  }

  @MainActor
  func update(amount newAmount: Double, in budget: Budget) throws {
    budget.amount += amount - newAmount
    amount = newAmount
    try save()
    rescheduleReminder()
  }

  @MainActor
  func setReminder(_ isOn: Bool) throws {
    isReminder = isOn
    rescheduleReminder()
    try save()
  }

  /// Pays the current period: charges the budget, records a contribution and moves the due date one period on
  @MainActor
  func renew(from budget: Budget) throws {
    guard let context = modelContext else { return }
    dueDate = nextDueDate
    rescheduleReminder()
    budget.amount -= amount
    let contribution = Source.Factory.createPaymentContribution(amount: amount, date: .now)
    // Insert first, then link from the child side only
    context.insert(contribution)
    contribution.payment = self
    try context.save()
  }

  /// Deletes the payment with its contributions; a payment not yet due gives its amount back
  @MainActor
  func delete(refunding budget: Budget) throws {
    if !isDue {
      budget.amount += amount
    }
    NotificationManager.shared.deleteNotification(for: self)
    try delete()
  }

  @MainActor
  static func disableAllReminders(in context: ModelContext? = nil) throws {
    let context = context ?? AppModelStore.mainContext
    try context.fetch(all).forEach { $0.isReminder = false }
    try context.save()
    NotificationManager.shared.deleteNotifications()
  }

  private func rescheduleReminder() {
    NotificationManager.shared.deleteNotification(for: self)
    if isReminder {
      NotificationManager.shared.scheduleTriggerNotification(for: self, withDelay: reminderType.delay)
    }
  }
}

extension PaymentContributions: ActiveRecord {}
