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
  @AppStorage("currencySign") private var currencySign = "$"
  var body: some View {
    EXBaseCard {
      VStack(alignment: .leading, spacing: 5, content: {
        Appearance.shared.icon
          .foregroundColor(.primaryGreen)
          .padding(.bottom, 5)
        Text("\(Appearance.shared.text) We estimated your weekly payments to make things faster")
          .font(.system(.headline, weight: .medium))
          .foregroundColor(.black)
        Divider()
          .foregroundColor(.border)
          .padding(.vertical, 5)
        HStack {
          smallInfoView(title: "Weeks in your plan", text: "\(goalVM.weeks)")
          Spacer()
          Text("\(currencySign)\(goalVM.amount.clean) / week")
            .font(.system(.headline, weight: .semibold))
            .foregroundColor(.primaryGreen)
        }
        .padding([.top,.leading,.trailing], 5)
      })
    }
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
      return Text("Close goal faster!").foregroundColor(.primaryGreen).font(.system(.headline, weight: .semibold))
    }
  }
}

// MARK: - Helper Views
extension GoalAnalyticsView {
  @ViewBuilder
  func smallInfoView(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(title)
        .font(.system(.footnote, weight: .regular))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.system(.subheadline, weight: .regular))
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
