//
//  GoalCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct GoalCell: View {
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
    GoalCell(goal: DefaultGoals.goal2).applyMargins()
  }
}
