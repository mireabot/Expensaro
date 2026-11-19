//
//  GoalsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/11/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftData

struct GoalsListView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var showAddGoalView = false
  @AppStorage("currencySign") private var currencySign = "USD"
  
  @State private var showListAnimation = false
  @Query(Goal.byDueDate) private var goals: [Goal]
  var body: some View {
    NavigationView {
      goalsScrollView()
        .fullScreenCover(isPresented: $showAddGoalView, content: {
          AddGoalView(goal: Goal())
        })
        .rootNavigationTitle(Appearance.shared.title)
    }
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
  @ViewBuilder
  func goalsScrollView() -> some View {
    if #available(iOS 26.0, *) {
      // Header sits in a safe area bar so goals scroll under it with the system edge effect
      ScrollView {
        goalsList()
      }
      .scrollBounceBehavior(.basedOnSize)
      .safeAreaBar(edge: .top) {
        goalOverviewContent()
      }
    } else {
      ScrollView {
        LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
          Section {
            goalsList()
          } header: {
            goalOverviewHeader()
          }
        }
      }
      .scrollBounceBehavior(.basedOnSize)
    }
  }
  
  @ViewBuilder
  func goalsList() -> some View {
    Group {
      if goals.isEmpty {
        EXEmptyStateView(type: .noGoals, isCard: false).padding(.top, 30)
      } else {
        ZStack {
          if showListAnimation {
            VStack(spacing: 10) {
              ForEach(goals) { goal in
                Button {
                  router.pushTo(view: EXNavigationViewBuilder.builder.makeView(GoalDetailView(goal: goal)))
                } label: {
                  EXGoalCell(goal: goal)
                }
                .buttonStyle(EXPlainButtonStyle())
              }
            }
          } else {
            EXGoalCellLoading()
          }
        }
        .applyMargins()
      }
    }
    .onFirstAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
        withAnimation(.smooth) {
          showListAnimation.toggle()
        }
      }
    }
  }
  
  @ViewBuilder
  func goalOverviewHeader() -> some View {
    goalOverviewContent()
      .background(
        Rectangle()
          .fill(Color.white)
          .cornerRadius(12)
          .shadowXS()
      )
  }
  
  func goalOverviewContent() -> some View {
    HStack {
      HStack {
        VStack(alignment: .leading, spacing: 3) {
          Text("You saved in total")
            .font(.system(.subheadline, weight: .regular))
            .foregroundColor(.darkGrey)
          Text("\(totalSavings.formattedAsCurrencySolid(with: currencySign))")
            .font(.system(.title3, weight: .medium))
        }
        Spacer()
        
        Button {
          showAddGoalView.toggle()
        } label: {
          HStack {
            Source.Images.ButtonIcons.add
            Text("Add goal")
              .font(.headlineSemibold)
          }
        }.buttonStyle(EXSmallButtonStyle())
        
      }
      .padding(.top, 5)
      .padding(.bottom, 15)
      .applyMargins()
    }
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
