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
  @State private var budgetAmount: String = "0.0"
  
  // MARK: Presentation
  @State private var showError = false
  var body: some View {
    // TODO: Create textfield same as in transaction view and make section with money left to current goal
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            EXTextFieldWithCurrency(value: $budgetAmount)
            Button {
              budgetAmount.removeLast()
              if budgetAmount.isEmpty { budgetAmount = "0.0" }
            } label: {
              Source.Images.System.remove
                .padding(10)
                .background(Color.backgroundGrey)
                .cornerRadius(20)
            }
            .buttonStyle(EXPlainButtonStyle())
            .disabled(budgetAmount == "0.0")
          }
        }
      }
      .safeAreaInset(edge: .bottom, content: {
        EXNumberKeyboard(textValue: $budgetAmount, submitAction: {
          validate {
            makeDismiss()
          }
        })
        .padding(.bottom, 15)
      })
      .popup(isPresented: $showError, view: {
        alertView()
      }, customize: {
        $0
          .isOpaque(true)
          .position(.top)
          .type(.floater())
          .autohideIn(1.5)
      })
      .applyMargins()
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

// MARK: - Validation
extension AddGoalTransactionView {
  func validate(completion: @escaping() -> Void) {
    if Double(budgetAmount) != 0 {
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
    goalTransaction.amount = Double(budgetAmount) ?? 0
    if let newGoal = goal.thaw(), let realm = newGoal.realm {
      try? realm.write {
        newGoal.currentAmount += Double(budgetAmount) ?? 0
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
