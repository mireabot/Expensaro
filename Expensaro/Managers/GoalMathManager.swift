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
  init() {
    
  }
  
  @Published var isLoading: Bool = false
  @Published var successRate: Double = 0
  @Published var rateInformation: GoalSuccessRate = .noData
  
  func calculateSuccessRate(monthlyExpensesBudget: Double, goalAmount: Double, daysToGoal: Int, daysInMonth: Int = 30) {
    withAnimation(.interactiveSpring) {
      isLoading = true
    }
    
    let totalBudgetForExpenses = monthlyExpensesBudget * (Double(daysToGoal) / Double(daysInMonth))
    successRate = (totalBudgetForExpenses / goalAmount) * 100
    infoForSuccessRate(successRate)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
      self.isLoading = false
    }
  }
  
  func infoForSuccessRate(_ successRate: Double) {
    switch successRate {
    case 0..<35:
      rateInformation = .highRisk
    case 35..<60:
      rateInformation = .moderateRisk
    case 60...100:
      rateInformation = .noRisk
    case let x where x > 100:
      rateInformation = .noRisk
    case let x where x < 0:
      rateInformation = .noData
    default:
      rateInformation = .noData
    }
  }
}

enum GoalSuccessRate {
  case noRisk
  case moderateRisk
  case highRisk
  case noData
  
  var title: String {
    switch self {
    case .noRisk:
      return "No risk"
    case .moderateRisk:
      return "Moderate risk"
    case .highRisk:
      return "High risk"
    case .noData:
      return "N/A"
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
    case .noData:
      return "N/A"
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
    case .noData:
      return .black
    }
  }
}
