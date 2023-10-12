//
//  GoalDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftUIIntrospect

struct GoalDetailView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  @State private var showAddMoney = false
  @State private var showEditGoal = false
  let goal: Goal
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing, content: {
        ScrollView {
          goalInfo()
          transactionList()
        }
        .applyMargins()
        .introspect(.scrollView, on: .iOS(.v16,.v17)) { scrollView in
          scrollView.bounces = false
        }
        
        bottomActionButton().padding(16)
      })
//      .sheet(isPresented: $showAddMoney, content: {
//        AddBudgetView(type: .addToGoal)
//          .presentationDetents([.large])
//      })
      .sheet(isPresented: $showEditGoal, content: {
        EditGoalView(selectedGoal: goal)
          .presentationDetents([.fraction(0.9)])
          .presentationDragIndicator(.visible)
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(goal.name)
            .font(.mukta(.medium, size: 17))
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .foregroundColor(.black)
          }
        }
      }
    }
  }
  
  @ViewBuilder
  func goalInfo() -> some View {
    VStack(alignment: .leading, spacing: 3) {
      HStack(alignment: .center, spacing: 3) {
        Text("$\(goal.currentAmount.clean)")
          .font(.mukta(.bold, size: 34))
          .foregroundColor(.black)
        Text(" / \(goal.goalAmount.clean)")
          .font(.mukta(.regular, size: 17))
          .foregroundColor(.darkGrey)
      }
      ProgressView(value: goal.currentAmount, total: goal.goalAmount, label: {})
        .tint(.primaryGreen)
      HStack(spacing: 25) {
        smallInfoView(title: "Money left", text: "$\(goal.amountLeft.clean)")
        smallInfoView(title: "Days left", text: "\(goal.daysLeft) days left")
      }
      .padding(.top, 5)
    }
    .padding(.top, 20)
  }
  
  @ViewBuilder
  func transactionList() -> some View {
    VStack(spacing: 10) {
      Text("Transactions")
        .font(.mukta(.semibold, size: 17))
        .frame(maxWidth: .infinity, alignment: .leading)
      LazyVStack(spacing: 10) {
        EXTransactionCell(transaction: TransactionData.sampleTransactions[0])
      }
    }
    .padding(.top, 20)
  }
}

struct GoalDetailView_Previews: PreviewProvider {
  static var previews: some View {
    GoalDetailView(goal: Goal.sampleGoals[1])
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
    VStack(alignment: .leading, spacing: -3) {
      Text(title)
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.mukta(.regular, size: 15))
    }
  }
  
  @ViewBuilder
  func bottomActionButton() -> some View {
    VStack {
      Menu {
        Button(action: { showAddMoney.toggle() }) {
          Label("Add money", image: "buttonTransaction")
        }
        
        Button(action: { showEditGoal.toggle() }) {
          Label("Edit goal", image: "buttonEdit")
        }
        
        Button(role: .destructive, action: {}) {
          Label("Delete goal", image: "buttonDelete")
        }
        
      } label: {
        Source.Images.Navigation.menu
          .foregroundColor(.primaryGreen)
          .padding(20)
          .background(Color.secondaryYellow)
          .cornerRadius(40)
      }
      .font(.mukta(.regular, size: 15))
      .menuOrder(.fixed)
    }
  }
}
