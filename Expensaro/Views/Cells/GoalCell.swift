//
//  GoalCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct GoalCell: View {
  let goalData: Goal
  
  init(goalData: Goal) {
    self.goalData = goalData
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Text(goalData.name)
          .font(.mukta(.medium, size: 15))
          .multilineTextAlignment(.leading)
        Spacer()
        AnyView(topRightView())
      }
      HStack(alignment: .center, spacing: 1) {
        Text("\(goalData.currentAmount.clean)")
          .font(.mukta(.medium, size: 15))
          .lineLimit(3)
        Text(" / $\(goalData.goalAmount.clean)")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 13))
          .lineLimit(3)
      }
      ProgressView(value: goalData.currentAmount, total: goalData.goalAmount, label: {})
        .tint(goalData.barTint)
      
      if goalData.isFailed || goalData.isCompleted {
        Text(goalData.goalTitle)
          .font(.mukta(.regular, size: 13))
          .foregroundColor(goalData.barTint)
      }
    }
    .padding(10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  func topRightView() -> any View {
    if goalData.isFailed {
      return AnyView(
        Text("Timer is over!")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 13))
      )
    }
    if goalData.isCompleted {
      return AnyView(
        Source.Images.System.completedGoal
          .foregroundColor(.green)
      )
    }
    else {
      return AnyView(
        Text("\(goalData.daysLeft) days left")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 13))
      )
    }
  }
}

struct GoalCell_Previews: PreviewProvider {
  static var previews: some View {
    GoalCell(goalData: Goal.sampleGoals[3]).applyMargins()
  }
}
