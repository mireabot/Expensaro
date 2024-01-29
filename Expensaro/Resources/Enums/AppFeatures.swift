//
//  AppFeatures.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/27/24.
//

import SwiftUI
import ExpensaroUIKit

/// Enum includes app features
enum AppFeatures: CaseIterable {
  case customCategories
  case smartGoalsPaymentSuggestions
  case goalSuccessRate
  case selectedCategoryBreakdown
  case paymentAlerts
  case topCategoryAnalytics
  case previousMonthRecap
  case recapCategoriesBreakdown
  
  var icon: Image {
    switch self {
    case .customCategories:
      return Source.Images.AppFeatures.customCategories
    case .smartGoalsPaymentSuggestions:
      return Source.Images.AppFeatures.smartGoalsPaymentSuggestions
    case .goalSuccessRate:
      return Source.Images.AppFeatures.goalSuccessRate
    case .selectedCategoryBreakdown:
      return Source.Images.AppFeatures.selectedCategoryBreakdown
    case .paymentAlerts:
      return Source.Images.AppFeatures.paymentAlerts
    case .topCategoryAnalytics:
      return Source.Images.AppFeatures.topCategoryAnalytics
    case .previousMonthRecap:
      return Source.Images.AppFeatures.previousMonthRecap
    case .recapCategoriesBreakdown:
      return Source.Images.AppFeatures.recapCategoriesBreakdown
    }
  }
  
  var title: String {
    switch self {
    case .customCategories:
      return "Personalized Categories"
    case .smartGoalsPaymentSuggestions:
      return "Smart Goal Payment Suggestions"
    case .goalSuccessRate:
      return "Goal Success Rate"
    case .selectedCategoryBreakdown:
      return "Selected Category Spending Analysis"
    case .paymentAlerts:
      return "Recurring Payment Notifications"
    case .topCategoryAnalytics:
      return "Monthly Top Category Analytics"
    case .previousMonthRecap:
      return "Previous Month Financial Recap"
    case .recapCategoriesBreakdown:
      return "Expense Analysis by Categories"
    }
  }
  
  var text: String {
    switch self {
    case .customCategories:
      return "Create and customize categories with fun emoji icons for a unique, personalized app experience"
    case .smartGoalsPaymentSuggestions:
      return "AI-driven suggestions for optimal goal payments based on your financial behavior"
    case .goalSuccessRate:
      return "Estimate your chance of achieving financial goals on time with our advanced model"
    case .selectedCategoryBreakdown:
      return "View average spending and top transactions in your selected categories"
    case .paymentAlerts:
      return "Receive timely alerts for upcoming recurring payments"
    case .topCategoryAnalytics:
      return "Identify your highest spending category each month and monitor overall expenses"
    case .previousMonthRecap:
      return "Review last month's budget, spending by category, and goal contributions"
    case .recapCategoriesBreakdown:
      return "Detailed and organized summary of expenses per category for better financial tracking"
    }
  }
}
