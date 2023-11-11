//
//  GoalAnalyticsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/2/23.
//

import SwiftUI
import ExpensaroUIKit

struct GoalAnalyticsView: View {
  @ObservedObject var goalVM: GoalAnalyticsViewModel
  var body: some View {
    VStack(alignment: .leading, spacing: 5, content: {
      Appearance.shared.icon
        .foregroundColor(.primaryGreen)
        .padding(8)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      Text("\(Appearance.shared.text) We estimated your weekly payments to complete goal faster")
        .font(.mukta(.semibold, size: 17))
        .foregroundColor(.black)
      Divider()
        .foregroundColor(.border)
      HStack {
        smallInfoView(title: "Weeks in your plan", text: "\(goalVM.weeks)")
        Spacer()
        Text("$\(goalVM.amount.clean)/week")
          .font(.mukta(.semibold, size: 17))
          .foregroundColor(.primaryGreen)
      }
      .padding([.top,.leading,.trailing], 5)
    })
    .background(.white)
    .padding(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.5)
        .stroke(Color.border, lineWidth: 1)
    )
  }
}

#Preview {
  GoalAnalyticsView(goalVM: GoalAnalyticsViewModel(goal: DefaultGoals.goal1)).applyMargins()
}

// MARK: - Appearance
extension GoalAnalyticsView {
  struct Appearance {
    static let shared = Appearance()
    
    let icon = Image(Source.Strings.Categories.Images.hobby)
    var text: Text {
      return Text("Close goal faster!").foregroundColor(.primaryGreen).font(.mukta(.semibold, size: 17))
    }
  }
}

// MARK: - Helper Views
extension GoalAnalyticsView {
  @ViewBuilder
  func smallInfoView(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: -3) {
      Text(title)
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.mukta(.regular, size: 15))
    }
  }
}


class GoalAnalyticsViewModel : ObservableObject {
  var goal: Goal
  @Published var weeks = 0
  @Published var amount: Double = 0
  
  init(goal: Goal) {
    self.goal = goal
    optimalAmountPerWeek()
    numberOfWeeks()
  }
  
  func optimalAmountPerWeek() {
    let calendar = Calendar.current
    let weeksUntilDueDate = calendar.dateComponents([.weekOfYear], from: goal.dateCreated, to: goal.dueDate).weekOfYear ?? 0
    
    if weeksUntilDueDate > 0 {
      amount = goal.finalAmount / Double(weeksUntilDueDate)
    }
  }
  
  func numberOfWeeks() {
    let calendar = Calendar.current
    let weeksUntilDueDate = calendar.dateComponents([.weekOfYear], from: goal.dateCreated, to: goal.dueDate).weekOfYear ?? 0
    weeks = max(0, weeksUntilDueDate)
  }
}
