//
//  GoalCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit
import Shimmer

struct EXGoalCell: View {
  let goal: Goal
  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      HStack {
        Text(goal.name)
          .font(.system(.subheadline, weight: .medium))
          .multilineTextAlignment(.leading)
        Spacer()
        AnyView(topRightView())
      }
      HStack(alignment: .center, spacing: 1) {
        Text("\(goal.currentAmount.clean)")
          .font(.system(.subheadline, weight: .medium))
          .lineLimit(3)
        Text(" / $\(goal.finalAmount.clean)")
          .foregroundColor(.darkGrey)
          .font(.system(.footnote, weight: .regular))
          .lineLimit(3)
      }
      ProgressView(value: goal.currentAmount, total: goal.finalAmount, label: {})
        .tint(goal.barTint)
      
      if goal.isFailed || goal.isCompleted {
        Text(goal.goalTitle)
          .font(.system(.footnote, weight: .regular))
          .foregroundColor(goal.barTint)
      }
    }
    .padding(12)
    .background(Color.backgroundGrey)
    .cornerRadius(16)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  func topRightView() -> any View {
    if goal.isFailed {
      return AnyView(
        Text("Timer is over!")
          .foregroundColor(.darkGrey)
          .font(.system(.footnote, weight: .regular))
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
          .font(.system(.footnote, weight: .regular))
      )
    }
  }
}

struct GoalCell_Previews: PreviewProvider {
  static var previews: some View {
    EXGoalCell(goal: DefaultGoals.goal1)
      .applyMargins()
  }
}

struct EXGoalCellLoading: View {
  var body: some View {
    VStack {
      EXGoalCell(goal: DefaultGoals.goal1)
        .redacted(reason: .placeholder)
        .shimmering()
      EXGoalCell(goal: DefaultGoals.goal1)
        .redacted(reason: .placeholder)
        .shimmering()
      EXGoalCell(goal: DefaultGoals.goal1)
        .redacted(reason: .placeholder)
        .shimmering()
    }
  }
}
