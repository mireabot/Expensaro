//
//  GoalAnalyticsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/2/23.
//

import SwiftUI

struct GoalAnalyticsView: View {
  var goal: Goal
  var body: some View {
    VStack {
      Text("\(optimalAmountPerWeek().clean)")
      Text("\(numberOfWeeks())")
    }
  }
}

#Preview {
  GoalAnalyticsView(goal: DefaultGoals.goal1)
}

// MARK: - Analytics Functions
extension GoalAnalyticsView {
  func optimalAmountPerWeek() -> Double {
    let currentDate = Date()
    let calendar = Calendar.current
    let weeksUntilDueDate = calendar.dateComponents([.weekOfYear], from: currentDate, to: goal.dueDate).weekOfYear ?? 0
    
    if weeksUntilDueDate > 0 {
      return goal.finalAmount / Double(weeksUntilDueDate)
    }
    return 0.0
  }
  
  func numberOfWeeks() -> Int {
    let currentDate = Date()
    let calendar = Calendar.current
    let weeksUntilDueDate = calendar.dateComponents([.weekOfYear], from: currentDate, to: goal.dueDate).weekOfYear ?? 0
    return max(0, weeksUntilDueDate)
  }
}
