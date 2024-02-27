//
//  AnalyticsManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/7/24.
//

import SwiftUI
import Aptabase

final class AnalyticsManager {
  private init() {}
  
  static let shared = AnalyticsManager()
  
  public func log(_ event: AnalyticsEvents) {
    if Source.adminMode {
      print("Admin mode")
    } else {
      switch event {
      case .createdBudget(let amount, let date):
        Aptabase.shared.trackEvent(event.name, with: ["amount" : amount, "date" : date])
      case .updatedBudget(let amount):
        Aptabase.shared.trackEvent(event.name, with: ["amount" : amount])
      case .createdReminder(let paymentName):
        Aptabase.shared.trackEvent(event.name, with: ["paymentName" : paymentName])
      case .deniedReminder(let paymentName):
        Aptabase.shared.trackEvent(event.name, with: ["paymentName" : paymentName])
      case .modifiedReminder(let paymentName):
        Aptabase.shared.trackEvent(event.name, with: ["paymentName" : paymentName])
      case .editPayment:
        Aptabase.shared.trackEvent(event.name)
      case .deletePayment:
        Aptabase.shared.trackEvent(event.name)
      case .createPayment(let name, let amount):
        Aptabase.shared.trackEvent(event.name, with: ["name" : name, "amount" : amount])
      case .createTransaction(let name, let amount, let category):
        Aptabase.shared.trackEvent(event.name, with: ["name" : name, "amount" : amount, "category" : category])
      case .madeNote(let text):
        Aptabase.shared.trackEvent(event.name, with: ["text" : text])
      case .openedSelectedAnalyticsPreview:
        Aptabase.shared.trackEvent(event.name)
      case .editTransaction:
        Aptabase.shared.trackEvent(event.name)
      case .deleteTransaction:
        Aptabase.shared.trackEvent(event.name)
      case .createGoal(let name, let amount):
        Aptabase.shared.trackEvent(event.name, with: ["name" : name, "amount" : amount])
      case .deleteGoal:
        Aptabase.shared.trackEvent(event.name)
      case .editGoal:
        Aptabase.shared.trackEvent(event.name)
      case .addMoneyToGoal(let amount):
        Aptabase.shared.trackEvent(event.name, with: ["amount" : amount])
      case .openTopCategoryPreview:
        Aptabase.shared.trackEvent(event.name)
      case .openMonthRecapPreview:
        Aptabase.shared.trackEvent(event.name)
      case .openTopCategory:
        Aptabase.shared.trackEvent(event.name)
      case .openMonthRecap:
        Aptabase.shared.trackEvent(event.name)
      case .openCategoryBreakdown:
        Aptabase.shared.trackEvent(event.name)
      case .createCategory(let name, let folder):
        Aptabase.shared.trackEvent(event.name, with: ["name" : name, "section" : folder])
      case .removeReminders:
        Aptabase.shared.trackEvent(event.name)
      case .deleteAccount:
        Aptabase.shared.trackEvent(event.name)
      case .sendFeedback(let date, let message, let email, let topic):
        Aptabase.shared.trackEvent(event.name, with: ["message" : message, "date" : date, "email" : email, "topic" : topic])
      case .paymentRenewed(let name, let amount):
        Aptabase.shared.trackEvent(event.name, with: ["name" : name, "amount" : amount])
      case .profileCreated:
        Aptabase.shared.trackEvent(event.name)
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
  case createPayment(String, Double)
  case createTransaction(String, Double, String)
  case paymentRenewed(String, Double)
  case madeNote(String)
  case openedSelectedAnalyticsPreview
  case editTransaction
  case deleteTransaction
  case createGoal(String, Double)
  case deleteGoal
  case editGoal
  case addMoneyToGoal(Double)
  case openTopCategoryPreview
  case openMonthRecapPreview
  case openTopCategory
  case openMonthRecap
  case openCategoryBreakdown
  case createCategory(String, String)
  case removeReminders
  case deleteAccount
  case sendFeedback(Date, String, String, String)
  case profileCreated
  
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
    case .paymentRenewed:
      return "Payment renewed"
    case .profileCreated:
      return "Profile created"
    }
  }
}
