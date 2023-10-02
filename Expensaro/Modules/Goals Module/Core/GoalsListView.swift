//
//  GoalsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/11/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftUIIntrospect

struct GoalsListView: View {
  @State private var showAddGoalView = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
          Section {
            LazyVStack(spacing: 10) {
              ForEach(Goal.sampleGoals) { goal in
                GoalCell(goalData: goal)
              }
            }
            .applyMargins()
          } header: {
            goalOverviewHeader()
          }

        }
      }
      .introspect(.scrollView, on: .iOS(.v16, .v17), customize: { scrollView in
        scrollView.bounces = false
      })
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showAddGoalView, content: {
        AddGoalView()
          .presentationDetents([.large])
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
          Text("$ \(calculateTotalSavings().clean)")
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
  
  @ViewBuilder
  func emptyState() -> some View {
    VStack(alignment: .center, spacing: 5) {
      Image("noGoals")
        .resizable()
        .frame(width: 120, height: 120)
      VStack(spacing: 0) {
        Text("No goals for now")
          .font(.mukta(.semibold, size: 20))
        Text("Set Goals, Achieve Dreams")
          .font(.mukta(.regular, size: 17))
          .foregroundColor(.darkGrey)
      }
    }
    .padding(.top, 30)
  }
}

// MARK: - Helper Functions
extension GoalsListView {
  func calculateTotalSavings() -> Float {
    var savings: Float = 0
    
    for goal in Goal.sampleGoals {
      savings += goal.currentAmount
    }
    
    return savings
  }
}
