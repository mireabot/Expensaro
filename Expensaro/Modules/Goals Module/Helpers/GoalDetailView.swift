//
//  GoalDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import SwiftData

struct GoalDetailView: View {
  // MARK: Essential
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Storage
  @Bindable var goal: Goal
  
  // MARK: Presentation
  @State private var showAnalytics = false
  var body: some View {
    ScrollView {
      goalInfo()
      transactionList()
    }
    .scrollBounceBehavior(.basedOnSize)
    .applyMargins()
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(goal.name)
          .font(.system(.headline, weight: .medium))
      }
      
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          router.back()
        } label: {
          Appearance.shared.backIcon
            .foregroundColor(.black)
        }
      }
    }
  }
  
  @ViewBuilder
  func goalInfo() -> some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack(alignment: .center, spacing: 3) {
        Text("\(goal.currentAmount.formattedAsCurrencySolid(with: currencySign))")
          .font(.system(.largeTitle, weight: .bold))
          .foregroundColor(.black)
        Text(" / \(goal.finalAmount.clean)")
          .font(.system(.headline, weight: .regular))
          .foregroundColor(.darkGrey)
      }
      ProgressView(value: goal.currentAmount, total: goal.finalAmount, label: {})
        .tint(.primaryGreen)
      HStack(spacing: 25) {
        if goal.isFailed {
          smallInfoView(title: "Money left", text: "\(goal.amountLeft.formattedAsCurrencySolid(with: currencySign))")
          smallInfoView(title: "Goal started", text: "\(Source.Functions.showString(from: goal.dateCreated))")
        }
        else if goal.isCompleted {
          smallInfoView(title: "Goal started", text: "\(Source.Functions.showString(from: goal.dateCreated))")
        }
        else {
          smallInfoView(title: "Money left", text: "\(goal.amountLeft.formattedAsCurrencySolid(with: currencySign))")
          smallInfoView(title: "Days left", text: "\(goal.isCompleted || goal.isFailed ? 0 : goal.daysLeft) days left")
          smallInfoView(title: "Goal started", text: "\(Source.Functions.showString(from: goal.dateCreated))")
        }
        
      }
      .padding(.top, 10)
      
      if goal.isCompleted {
        EXInfoCard(config: ("Champ Champ!",
                            "You have completed this goal ahead of time. Do your best to close others same way!"),
                   icon: .image(Source.Images.InfoCardIcon.topCategory))
          .padding(.top, 10)
      }
      
      else if goal.isFailed {
        EXInfoCard(config: ("Not this time :(",
                            "You couldn't finish goal before deadline, but you can still make it with other goals!"),
                   icon: .image(Source.Images.InfoCardIcon.missedGoal))
          .padding(.top, 10)
      }
      else {
        GoalAnalyticsView(goalService: GoalAnalyticsService(goal: goal))
          .padding(.top, 10)
      }
    }
    .padding(.top, 20)
  }
  
  @ViewBuilder
  func transactionList() -> some View {
    VStack(spacing: 10) {
      Text("Contributions")
        .font(.system(.headline, weight: .semibold))
        .frame(maxWidth: .infinity, alignment: .leading)
      if goal.transactions.isEmpty {
        EXEmptyStateView(type: .noTransactionForGoal)
      } else {
        LazyVStack(spacing: 10) {
          ForEach(goal.transactionsNewestFirst) { goalTransaction in
            EXGoalTransactionCell(goalTransaction: goalTransaction)
          }
        }
      }
    }
    .padding(.top, 20)
  }
}

struct GoalDetailView_Previews: PreviewProvider {
  static var previews: some View {
    GoalDetailView(goal: Source.DefaultData.sampleGoals[0])
      .modelContainer(AppModelStore.preview)
  }
}

// MARK: - Appearance
extension GoalDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let backIcon = Source.Images.Navigation.back
    let menuIcon = Source.Images.Navigation.menu
  }
}

// MARK: - Helper Views
extension GoalDetailView {
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
