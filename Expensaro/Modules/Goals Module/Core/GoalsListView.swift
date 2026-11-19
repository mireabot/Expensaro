//
//  GoalsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/11/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import SwiftData

struct GoalsListView: View {
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  @Query(Goal.byDueDate) private var goals: [Goal]
  var body: some View {
    goalsScrollView()
      .rootNavigationTitle(Appearance.shared.title)
  }
}

struct GoalsListView_Previews: PreviewProvider {
  static var previews: some View {
    GoalsListView()
      .modelContainer(AppModelStore.preview)
  }
}

// MARK: - Apperance
extension GoalsListView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Goals"
  }
}

// MARK: - Helper Views
extension GoalsListView {
  func goalsScrollView() -> some View {
    ScrollView {
      VStack(spacing: 10) {
        goalOverviewContent()
        goalsList()
      }
    }
    .scrollBounceBehavior(.basedOnSize)
  }
  
  @ViewBuilder
  func goalsList() -> some View {
    if goals.isEmpty {
      EXEmptyStateView(type: .noGoals, isCard: false).padding(.top, 30)
    } else {
      VStack(spacing: 10) {
        ForEach(goals) { goal in
          Button {
            router.navigate(to: .goalDetail(goal))
          } label: {
            EXGoalCell(goal: goal)
          }
          .buttonStyle(EXPlainButtonStyle())
        }
      }
      .applyMargins()
    }
  }
  
  func goalOverviewContent() -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text("You saved in total")
        .font(.system(.subheadline, weight: .regular))
        .foregroundColor(.darkGrey)
      Text("\(totalSavings.formattedAsCurrencySolid(with: currencySign))")
        .font(.system(.title3, weight: .medium))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.top, 5)
    .padding(.bottom, 15)
    .applyMargins()
  }
}

// MARK: - Helper Functions
extension GoalsListView {
  var totalSavings: Double {
    var total: Double = 0
    for i in goals {
      total += i.currentAmount
    }
    return total
  }
}
