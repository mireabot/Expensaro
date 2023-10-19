//
//  GoalCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXGoalCell: View {
  let goal: Goal
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Text(goal.name)
          .font(.mukta(.medium, size: 15))
          .multilineTextAlignment(.leading)
        Spacer()
        AnyView(topRightView())
      }
      HStack(alignment: .center, spacing: 1) {
        Text("\(goal.currentAmount.clean)")
          .font(.mukta(.medium, size: 15))
          .lineLimit(3)
        Text(" / $\(goal.finalAmount.clean)")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 13))
          .lineLimit(3)
      }
      ProgressView(value: goal.currentAmount, total: goal.finalAmount, label: {})
        .tint(goal.barTint)
      
      if goal.isFailed || goal.isCompleted {
        Text(goal.goalTitle)
          .font(.mukta(.regular, size: 13))
          .foregroundColor(goal.barTint)
      }
    }
    .padding(10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  func topRightView() -> any View {
    if goal.isFailed {
      return AnyView(
        Text("Timer is over!")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 13))
      )
    }
    if goal.isCompleted {
      return AnyView(
        Source.Images.System.completedGoal
          .foregroundColor(.green)
      )
    }
    else {
      return AnyView(
        Text("\(goal.daysLeft) days left")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 13))
      )
    }
  }
}

struct GoalCell_Previews: PreviewProvider {
  static var previews: some View {
    EXGoalCell(goal: DefaultGoals.goal2).applyMargins()
  }
}

// MARK: Computer properties for goal
extension Goal {
  var daysLeft: Int {
    let calendar = Calendar.current
    let currentDate = Date()
    let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
    return components.day ?? 0
  }
  
  var amountLeft: Double {
    return finalAmount - currentAmount
  }
  
  var isCompleted: Bool {
    return currentAmount >= finalAmount
  }
  
  var isFailed: Bool {
    return currentAmount < finalAmount && Date() >= dueDate
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
