//
//  Goal.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct Goal: Identifiable {
  var id = UUID().uuidString
  var name: String
  var goalAmount: Float
  var currentAmount: Float
  var goalDate: Date
  
  var daysLeft: Int {
    let calendar = Calendar.current
    let currentDate = Date()
    let components = calendar.dateComponents([.day], from: currentDate, to: goalDate)
    return components.day ?? 0
  }
  
  var amountLeft: Float {
    return goalAmount - currentAmount
  }
  
  var isCompleted: Bool {
    return currentAmount >= goalAmount
  }
  
  var isFailed: Bool {
    return currentAmount < goalAmount && Date() >= goalDate
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
  
  static let sampleGoals: [Goal] = [
    Goal(name: "Vacation Fund", goalAmount: 1000.0, currentAmount: 350.0, goalDate: Date().addingTimeInterval(60 * 60 * 24 * 90)),
    Goal(name: "New Laptop", goalAmount: 1500.0, currentAmount: 700.0, goalDate: Date().addingTimeInterval(60 * 60 * 24 * 120)),
    Goal(name: "Fitness Membership", goalAmount: 500.0, currentAmount: 200.0, goalDate: Date().addingTimeInterval(60 * 60 * 24 * 60)),
    Goal(name: "Completed Goal", goalAmount: 200.0, currentAmount: 200.0, goalDate: Date()), // Completed goal
    Goal(name: "Failed Goal", goalAmount: 1000.0, currentAmount: 500.0, goalDate: Date().addingTimeInterval(-60 * 60 * 24 * 30)), // Failed goal (past date)
  ]
}
