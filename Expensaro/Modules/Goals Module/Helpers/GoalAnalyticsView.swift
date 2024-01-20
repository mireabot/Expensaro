//
//  GoalAnalyticsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/2/23.
//

import SwiftUI
import ExpensaroUIKit

struct GoalAnalyticsView: View {
  @ObservedObject var goalService: GoalAnalyticsService
  @AppStorage("currencySign") private var currencySign = "$"
  var body: some View {
    EXBaseCard {
      VStack(alignment: .leading, spacing: 5, content: {
        Appearance.shared.icon
          .foregroundColor(.primaryGreen)
          .padding(.bottom, 5)
        Text("\(Appearance.shared.text) We estimated your payments to make things faster")
          .font(.system(.headline, weight: .medium))
          .foregroundColor(.black)
        Divider()
          .foregroundColor(.border)
          .padding(.vertical, 5)
        HStack {
          smallInfoView(title: goalService.timeUnitTitle, text: "\(goalService.timeUnits)")
          Spacer()
          Text("\(currencySign)\(goalService.amountPerTimeUnit.clean) / \(goalService.timeUnitName)")
            .font(.system(.headline, weight: .semibold))
            .foregroundColor(.primaryGreen)
        }
        .padding([.top,.leading,.trailing], 5)
      })
    }
  }
}

#Preview {
  GoalAnalyticsView(goalService: GoalAnalyticsService(goal: DefaultGoals.goal1)).applyMargins()
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


final class GoalAnalyticsService : ObservableObject {
  private enum TimeUnit {
    case week
    case month
    
    var title: String {
      switch self {
      case .week:
        return "Weeks in your plan"
      case .month:
        return "Months in your plan"
      }
    }
    
    var name: String {
      switch self {
      case .week:
        return "week"
      case .month:
        return "month"
      }
    }
  }
  
  var goal: Goal
  @Published var timeUnits = 0
  @Published var amountPerTimeUnit: Double = 0
  @Published var timeUnitTitle: String = ""
  @Published var timeUnitName: String = ""
  
  private var timeUnitType: TimeUnit {
    didSet {
      timeUnitTitle = timeUnitType.title
      timeUnitName = timeUnitType.name
    }
  }
  
  init(goal: Goal) {
    self.goal = goal
    self.timeUnitType = .month
    calculateTimeUnitsAndAmount()
  }
  
  func calculateTimeUnitsAndAmount() {
    let calendar = Calendar.current
    let monthsUntilDueDate = calendar.dateComponents([.month], from: goal.dateCreated, to: goal.dueDate).month ?? 0
    let weeksUntilDueDate = calendar.dateComponents([.weekOfYear], from: goal.dateCreated, to: goal.dueDate).weekOfYear ?? 0
    
    if monthsUntilDueDate < 2 {
      timeUnitType = .week
      timeUnits = max(0, weeksUntilDueDate)
    } else {
      timeUnitType = .month
      timeUnits = max(0, monthsUntilDueDate)
    }
    amountPerTimeUnit = goal.finalAmount / Double(timeUnits)
  }
}
