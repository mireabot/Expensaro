//
//  GoalMathManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/18/24.
//

import Foundation
import Combine

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
