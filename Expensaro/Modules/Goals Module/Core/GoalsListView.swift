//
//  GoalsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/11/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftUIIntrospect
import RealmSwift

struct GoalsListView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var showAddGoalView = false
  
  @ObservedResults(Goal.self, sortDescriptor: SortDescriptor(keyPath: \Goal.dueDate, ascending: true)) var goals
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
          Section {
            if goals.isEmpty {
              EXEmptyStateView(type: .noGoals, isCard: false).padding(.top, 30)
            } else {
              LazyVStack(spacing: 10) {
                ForEach(goals) { goal in
                  Button {
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(GoalDetailView(goal: goal)))
                  } label: {
                    EXGoalCell(goal: goal)
                  }
                  .buttonStyle(EXPlainButtonStyle())
                }
              }
              .applyMargins()
            }
          } header: {
            goalOverviewHeader()
          }
        }
      }
      .introspect(.scrollView, on: .iOS(.v16, .v17), customize: { scrollView in
        scrollView.bounces = false
      })
      .navigationBarTitleDisplayMode(.inline)
      .fullScreenCover(isPresented: $showAddGoalView, content: {
        AddGoalView(goal: Goal())
      })
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 24))
        }
      }
    }
  }
}

struct GoalsListView_Previews: PreviewProvider {
  static var previews: some View {
    GoalsListView()
      .environment(\.realmConfiguration, RealmMigrator.configuration)
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
  func goalOverviewHeader() -> some View {
    HStack {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Text("You saved in total")
            .font(.mukta(.regular, size: 15))
            .foregroundColor(.darkGrey)
          Text("$\(totalSavings.clean)")
            .font(.mukta(.medium, size: 20))
        }
        Spacer()
        
        Button {
          showAddGoalView.toggle()
        } label: {
          HStack(spacing: 5) {
            Source.Images.ButtonIcons.add
            
            Text("Add goal")
              .font(.mukta(.semibold, size: 15))
          }
        }.buttonStyle(SmallButtonStyle())
        
      }
      .padding(.top, 5)
      .padding(.bottom, 15)
      .applyMargins()
    }
    .background(
      Rectangle()
        .fill(Color.white)
        .cornerRadius(12)
        .shadowXS()
    )
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
