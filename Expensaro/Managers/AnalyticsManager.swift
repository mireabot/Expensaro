//
//  AnalyticsManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/7/24.
//

import SwiftUI
import PostHog

final class AnalyticsManager {
  private init() {}
  
  static let shared = AnalyticsManager()
  
  public func log(_ event: AnalyticsEvents) {
    if Source.adminMode {
      print("Admin mode")
    } else {
      switch event {
      case .createdBudget(let amount, let date):
        PHGPostHog.shared()?.capture(event.name, properties: ["amount" : amount, "date" : date])
      case .updatedBudget(let amount):
        PHGPostHog.shared()?.capture(event.name, properties: ["amount" : amount])
      case .createdReminder(let paymentName):
        PHGPostHog.shared()?.capture(event.name, properties: ["paymentName" : paymentName])
      case .deniedReminder(let paymentName):
        PHGPostHog.shared()?.capture(event.name, properties: ["paymentName" : paymentName])
      case .modifiedReminder(let paymentName):
        PHGPostHog.shared()?.capture(event.name, properties: ["paymentName" : paymentName])
      case .editPayment:
        PHGPostHog.shared()?.capture(event.name)
      case .deletePayment:
        PHGPostHog.shared()?.capture(event.name)
      case .createPayment:
        PHGPostHog.shared()?.capture(event.name)
      case .createTransaction:
        PHGPostHog.shared()?.capture(event.name)
      case .madeNote(let text):
        PHGPostHog.shared()?.capture(event.name, properties: ["text" : text])
      case .openedSelectedAnalyticsPreview:
        PHGPostHog.shared()?.capture(event.name)
      case .editTransaction:
        PHGPostHog.shared()?.capture(event.name)
      case .deleteTransaction:
        PHGPostHog.shared()?.capture(event.name)
      case .createGoal:
        PHGPostHog.shared()?.capture(event.name)
      case .deleteGoal:
        PHGPostHog.shared()?.capture(event.name)
      case .editGoal:
        PHGPostHog.shared()?.capture(event.name)
      case .addMoneyToGoal(let amount):
        PHGPostHog.shared()?.capture(event.name, properties: ["amount" : amount])
      case .openTopCategoryPreview:
        PHGPostHog.shared()?.capture(event.name)
      case .openMonthRecapPreview:
        PHGPostHog.shared()?.capture(event.name)
      case .openTopCategory:
        PHGPostHog.shared()?.capture(event.name)
      case .openMonthRecap:
        PHGPostHog.shared()?.capture(event.name)
      case .openCategoryBreakdown:
        PHGPostHog.shared()?.capture(event.name)
      case .createCategory:
        PHGPostHog.shared()?.capture(event.name)
      case .removeReminders:
        PHGPostHog.shared()?.capture(event.name)
      case .deleteAccount:
        PHGPostHog.shared()?.capture(event.name)
      case .sendFeedback(let date, let message, let email):
        PHGPostHog.shared()?.capture(event.name, properties: ["message" : message, "date" : date, "email" : email])
      }
    }
  }
  
}

enum AnalyticsEvents {
  case createdBudget(Double, Date)
  case updatedBudget(Double)
  case createdReminder(String)
  case deniedReminder(String)
  case modifiedReminder(String)
  case editPayment
  case deletePayment
  case createPayment
  case createTransaction
  case madeNote(String)
  case openedSelectedAnalyticsPreview
  case editTransaction
  case deleteTransaction
  case createGoal
  case deleteGoal
  case editGoal
  case addMoneyToGoal(Double)
  case openTopCategoryPreview
  case openMonthRecapPreview
  case openTopCategory
  case openMonthRecap
  case openCategoryBreakdown
  case createCategory
  case removeReminders
  case deleteAccount
  case sendFeedback(Date, String, String)
  
  var name: String {
    switch self {
    case .createdBudget:
      return "Budget created"
    case .updatedBudget:
      return "Budget updated"
    case .createdReminder:
      return "Payment reminder created"
    case .deniedReminder:
      return "Payment reminder denied"
    case .modifiedReminder:
      return "Payment reminder toggled"
    case .editPayment:
      return "Payment edited"
    case .deletePayment:
      return "Payment deleted"
    case .createPayment:
      return "Payment created"
    case .createTransaction:
      return "Transaction created"
    case .madeNote:
      return "Note added"
    case .openedSelectedAnalyticsPreview:
      return "Selected analytics preview opened"
    case .editTransaction:
      return "Transaction edited"
    case .deleteTransaction:
      return "Transaction deleted"
    case .createGoal:
      return "Goal created"
    case .deleteGoal:
      return "Goal deleted"
    case .editGoal:
      return "Goal edited"
    case .addMoneyToGoal:
      return "Money added to goal"
    case .openTopCategoryPreview:
      return "Top category preview opened"
    case .openMonthRecapPreview:
      return "Month recap preview opened"
    case .openTopCategory:
      return "Top category analytics opened"
    case .openMonthRecap:
      return "Month recap analytics opened"
    case .openCategoryBreakdown:
      return "Categories breakdown opened"
    case .createCategory:
      return "Category created"
    case .removeReminders:
      return "All reminders deleted"
    case .deleteAccount:
      return "Account deleted"
    case .sendFeedback:
      return "Feedback sent"
    }
  }
}
