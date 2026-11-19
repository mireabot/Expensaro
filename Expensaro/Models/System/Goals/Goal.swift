//
//  Goal.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import Foundation
import ExpensaroUIKit
import SwiftData
import SwiftUI

extension ExpensaroSchemaV1 {
  @Model
  final class Goal {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String = ""
    var finalAmount: Double = 0
    var currentAmount: Double = 0
    var dueDate: Date = Date()
    var dateCreated: Date = Date()

    // The inverse is declared on this side only; GoalTransaction.goal is the plain to-one end
    @Relationship(deleteRule: .cascade, inverse: \GoalTransaction.goal)
    var transactions: [GoalTransaction] = []

    init() {}
  }

  @Model
  final class GoalTransaction {
    @Attribute(.unique) var id: String = UUID().uuidString
    var amount: Double = 0
    var note: String = ""
    var date: Date = Date()
    var goal: Goal?

    init() {}
  }
}

// MARK: Computed properties for goal
extension Goal {
  var daysLeft: Int {
    let calendar = Calendar.current
    let fromDate = calendar.startOfDay(for: Date())
    let toDate = calendar.startOfDay(for: dueDate)
    let numberOfDays = calendar.dateComponents([.day], from: fromDate, to: toDate)
    
    return numberOfDays.day!
  }
  
  var amountLeft: Double {
    return finalAmount - currentAmount
  }
  
  var isCompleted: Bool {
    return currentAmount >= finalAmount
  }
  
  var isFailed: Bool {
    return currentAmount < finalAmount && Source.Functions.localDate(with: .now) >= Source.Functions.localDate(with: dueDate)
  }
  
  var goalTitle: String {
    if isCompleted {
      return "Congrats! You reached your goal"
    }
    if isFailed {
      return "Sorry to see, but you failed to collect full amount"
    }
    else {
      return ""
    }
  }
  
  var barTint: Color {
    if isCompleted {
      return .green
    }
    if isFailed {
      return .red
    }
    else {
      return .primaryGreen
    }
  }
}

// MARK: Goal success estimate
/// Chance of reaching a goal on time, from the month's initial budget spread over the days left
struct GoalSuccessEstimate {
  let successRate: Double

  init(monthlyExpensesBudget: Double, goalAmount: Double, daysToGoal: Int, daysInMonth: Int = 30) {
    let totalBudgetForExpenses = monthlyExpensesBudget * (Double(daysToGoal) / Double(daysInMonth))
    successRate = (totalBudgetForExpenses / goalAmount) * 100
  }

  var rateInformation: GoalSuccessRate {
    switch successRate {
    case 0..<35:
      return .highRisk
    case 35..<60:
      return .moderateRisk
    case let rate where rate >= 60:
      return .noRisk
    default:
      return .noData
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
