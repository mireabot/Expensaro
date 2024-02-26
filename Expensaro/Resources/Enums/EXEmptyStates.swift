//
//  EXEmptyStates.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/3/23.
//

import SwiftUI
import ExpensaroUIKit

/// Enum for empty states
enum EXEmptyStates {
  // With icons
  case noCustomCategories
  case noTransactionInsights
  case noRecurringPayments
  case noTransactionForGoal
  case noRecapGoals
  case noRecapTransactions
  case noDailyTransactionsInsights
  
  // With images
  case noGoals
  case noTransactions
  case noDailyTransactions
  
  var title: Text {
    switch self {
    case .noCustomCategories:
      return Text("Create own category").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    case .noTransactionInsights:
      return Text("Unlock category insights.").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    case .noRecurringPayments:
      return Text("No payments due.").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    case .noTransactionForGoal:
      return Text("Use menu button").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    case .noGoals:
      return  Text("No goals for now").font(.system(.title3, weight: .bold))
    case .noTransactions:
      return Text("You have no transactions").font(.system(.title3, weight: .bold))
    case .noRecapGoals:
      return Text("No goal contributions made.").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    case .noRecapTransactions:
      return Text("No transactions made.").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    case .noDailyTransactions:
      return  Text("No daily transactions for now").font(.system(.title3, weight: .bold))
    case .noDailyTransactionsInsights:
      return Text("Get Daily Transaction Insights.").font(.system(.headline, weight: .bold)).foregroundColor(.primaryGreen)
    }
  }
  
  var text: String {
    switch self {
    case .noCustomCategories:
      return "by tapping button on the top"
    case .noTransactionInsights:
      return "Add at least five transactions to see more details"
    case .noRecurringPayments:
      return "Create a new one by tapping + button on the top"
    case .noTransactionForGoal:
      return "to make a payment towards goal"
    case .noGoals:
      return "Create a new one with plus icon on the top"
    case .noTransactions:
      return "Set Goals, Achieve Dreams"
    case .noRecapGoals:
      return "Better to save next month"
    case .noRecapTransactions:
      return "Maybe you forgot about writing them"
    case .noDailyTransactions:
      return "Create a new one with button on the top"
    case .noDailyTransactionsInsights:
      return "Elevate your understanding of where your money goes each day"
    }
  }
  
  var image: Image {
    switch self {
    case .noCustomCategories:
      return Source.Images.EmptyStates.noCategories
    case .noTransactionInsights:
      return Source.Images.EmptyStates.noInsights
    case .noRecurringPayments:
      return Source.Images.EmptyStates.noRecurringPayments
    case .noTransactionForGoal:
      return Source.Images.EmptyStates.noGoalTransaction
    case .noGoals:
      return Source.Images.EmptyStates.noGoals
    case .noTransactions:
      return Source.Images.EmptyStates.noTransactions
    case .noRecapGoals:
      return Source.Images.Onboarding.goals
    case .noRecapTransactions:
      return Image(Source.Images.Tabs.home)
    case .noDailyTransactions:
      return Source.Images.EmptyStates.noDailyTransactions
    case .noDailyTransactionsInsights:
      return Source.Images.EmptyStates.noInsights
    }
  }
}
