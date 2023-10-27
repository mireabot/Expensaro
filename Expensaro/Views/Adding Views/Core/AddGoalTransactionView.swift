//
//  AddGoalTransactionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/19/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct AddGoalTransactionView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var goalTransaction: GoalTransaction
  @ObservedRealmObject var goal: Goal
  
  // MARK: Variables
  @State private var amountValue: String = "0.0"
  @State private var budgetValue: Double = 0
  
  // MARK: Presentation
  @State private var showError = false
  var body: some View {
    // TODO: Create textfield same as in transaction view and make section with money left to current goal
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            goalTransactionTextField()
            moneyLeft()
          }
        }
        EXNumberKeyboard(textValue: $amountValue, submitAction: {
          validate {
            makeDismiss()
          }
        })
      })
      .popup(isPresented: $showError, view: {
        EXErrorView(type: .constant(.zeroAmount))
      }, customize: {
        $0
          .isOpaque(true)
          .position(.top)
          .type(.floater())
          .autohideIn(1.5)
      })
      .applyMargins()
      .onAppear {
        budgetValue = goal.amountLeft
      }
      .scrollDisabled(true)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

// MARK: - Apperance
extension AddGoalTransactionView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Add money towards goal"
    
    let closeIcon = Source.Images.Navigation.close
  }
}

// MARK: - Helper Views
extension AddGoalTransactionView {
  @ViewBuilder
  func goalTransactionTextField() -> some View {
    HStack {
      Text("$")
        .font(.mukta(.medium, size: 24))
      TextField("", text: $amountValue)
        .font(.mukta(.medium, size: 40))
        .tint(.clear)
        .multilineTextAlignment(.leading)
      
      Spacer()
      
      Button {
        amountValue.removeLast()
        if amountValue.isEmpty { amountValue = "0.0" }
      } label: {
        Source.Images.System.remove
          .padding(10)
          .background(Color.backgroundGrey)
          .cornerRadius(20)
      }
      .buttonStyle(EXPlainButtonStyle())
      .disabled(amountValue == "0.0")
    }
  }
  
  @ViewBuilder
  func moneyLeft() -> some View {
    HStack {
      Text("Remaining funds: $\(budgetValue.clean)")
        .font(.mukta(.medium, size: 17))
        .foregroundStyle(Color.primaryGreen)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// MARK: - Validation
extension AddGoalTransactionView {
  func validate(completion: @escaping() -> Void) {
    if Double(amountValue) != 0 {
      createGoalTransaction()
      completion()
    } else {
      showError.toggle()
    }
  }
  
  @ViewBuilder
  func alertView() -> some View {
    HStack {
      Source.Images.System.alertError
        .foregroundColor(.red)
      Text("Invalid entry")
        .font(.mukta(.medium, size: 17))
        .foregroundColor(.red)
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}

// MARK: - Realm Functions
extension AddGoalTransactionView {
  func createGoalTransaction() {
    goalTransaction.amount = Double(amountValue) ?? 0
    if let newGoal = goal.thaw(), let realm = newGoal.realm {
      try? realm.write {
        newGoal.currentAmount += Double(amountValue) ?? 0
        newGoal.transactions.append(goalTransaction)
      }
    }
  }
}



struct AddGoalTransactionView_Previews: PreviewProvider {
  static var previews: some View {
    AddGoalTransactionView(goalTransaction: GoalTransaction(), goal: Goal())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}
