//
//  GoalMathManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/18/24.
//

import Foundation
import Combine
import SwiftUI

final class GoalMathManager: ObservableObject {
  static let shared = GoalMathManager()
  private init() {}
  
  @Published var isLoading: Bool = false
  @Published var successRate: Double = 0
  
  func calculateSuccessRate(monthlyExpensesBudget: Double, goalAmount: Double, daysToGoal: Int, daysInMonth: Int = 30) {
    isLoading = true
    
    let totalBudgetForExpenses = monthlyExpensesBudget * (Double(daysToGoal) / Double(daysInMonth))
    successRate = (totalBudgetForExpenses / goalAmount) * 100
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
      self.isLoading = false
    }
  }
}

private enum GoalSuccessRate {
  case noRisk
  case moderateRisk
  case highRisk
  
  var title: String {
    switch self {
    case .noRisk:
      return "No risk"
    case .moderateRisk:
      return "Moderate risk"
    case .highRisk:
      return "High risk"
    }
  }
  
  var text: String {
    switch self {
    case .noRisk:
      return "Your financials are looking healthy for this goal. It's a favorable time to get started!"
    case .moderateRisk:
      return "With careful budgeting and planning, initiating this goal could be feasible"
    case .highRisk:
      return "Starting this goal now will be challenging. It may be wise to wait until your situation improves"
    }
  }
  
  var color: Color {
    switch self {
    case .noRisk:
      return .green
    case .moderateRisk:
      return .yellow
    case .highRisk:
      return .red
    }
  }
}
