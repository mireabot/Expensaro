//
//  GoalDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftUIIntrospect
import RealmSwift
import PopupView

struct GoalDetailView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // MARK: Realm
  @ObservedRealmObject var goal: Goal
  
  // MARK: Presentation
  @State private var showAddMoney = false
  @State private var showEditGoal = false
  @State private var showDeleteAlert = false
  
  @State private var showAnalytics = false
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
      .popup(isPresented: $showDeleteAlert) {
        EXAlert(type: .deleteGoal, primaryAction: { deleteGoal() }, secondaryAction: { showDeleteAlert.toggle() }).applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .fullScreenCover(isPresented: $showAddMoney, content: {
        AddGoalTransactionView(goalTransaction: GoalTransaction(), goal: goal)
      })
      .fullScreenCover(isPresented: $showEditGoal, content: {
        EditGoalView(goal: goal)
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
        Text(" / \(goal.finalAmount.clean)")
          .font(.mukta(.regular, size: 17))
          .foregroundColor(.darkGrey)
      }
      ProgressView(value: goal.currentAmount, total: goal.finalAmount, label: {})
        .tint(.primaryGreen)
      HStack(spacing: 25) {
        smallInfoView(title: "Money left", text: "$\(goal.amountLeft.clean)")
        smallInfoView(title: "Days left", text: "\(goal.isCompleted || goal.isFailed ? 0 : goal.daysLeft) days left")
      }
      .padding(.top, 5)
      
      if goal.isCompleted {
        EXInfoCard(title: "Champ Champ!", icon: Source.Images.InfoCardIcon.topCategory, text: "You have completed this goal ahead of time. Do your best to close others same way!")
          .padding(.top, 10)
      }
      
      else if goal.isFailed {
        EXInfoCard(title: "Not this time:(", icon: Source.Images.InfoCardIcon.topCategory, text: "You couldn't finish goal before deadline, but you can still make it with other goals!")
          .padding(.top, 10)
      }
      else {
        GoalAnalyticsView(goalVM: GoalAnalyticsViewModel(goal: goal))
          .padding(.top, 10)
      }
    }
    .padding(.top, 20)
  }
  
  @ViewBuilder
  func transactionList() -> some View {
    VStack(spacing: 10) {
      Text("Transactions")
        .font(.mukta(.semibold, size: 17))
        .frame(maxWidth: .infinity, alignment: .leading)
      if goal.transactions.isEmpty {
        emptyState()
      } else {
        LazyVStack(spacing: 10) {
          ForEach(goal.transactions) { goalTransaction in
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
    GoalDetailView(goal: DefaultGoals.goal1)
      .environment(\.realmConfiguration, RealmMigrator.configuration)
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
        if goal.isCompleted || goal.isFailed {
          Button(role: .destructive, action: { showDeleteAlert.toggle() }) {
            Label("Delete goal", image: "buttonDelete")
          }
          
        } else {
          Button(action: { showAddMoney.toggle() }) {
            Label("Add money", image: "buttonTransaction")
          }
          
          Button(action: { showEditGoal.toggle() }) {
            Label("Edit goal", image: "buttonEdit")
          }
          
          Button(role: .destructive, action: { showDeleteAlert.toggle() }) {
            Label("Delete goal", image: "buttonDelete")
          }
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
  
  @ViewBuilder
  func emptyState() -> some View {
    VStack(alignment: .center, spacing: 3) {
      Text("You have no transactions related to this goal")
        .font(.mukta(.semibold, size: 15))
        .multilineTextAlignment(.center)
      Text("You can create one with menu button")
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 20)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}

// MARK: - Realm Functions
extension GoalDetailView {
  func deleteGoal() {
    showDeleteAlert.toggle()
    if let newGoal = goal.thaw(), let realm = newGoal.realm {
      try? realm.write {
        realm.delete(newGoal)
      }
      router.nav?.popViewController(animated: true)
    }
  }
}
