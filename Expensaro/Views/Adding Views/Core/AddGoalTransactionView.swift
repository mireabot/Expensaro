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
  @AppStorage("currencySign") private var currencySign = "USD"
  
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
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          VStack(alignment: .leading, spacing: 10) {
            goalTransactionTextField()
            moneyLeft()
          }
          .padding(.top, 20)
        }
        .scrollBounceBehavior(.basedOnSize)
        
        EXNumberKeyboard(textValue: $amountValue, submitAction: {
          validate {
            makeDismiss()
          }
        })
      })
      .popup(isPresented: $showError, view: {
        EXToast(type: .constant(.zeroAmount))
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
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
      Text(Locale.current.localizedCurrencySymbol(forCurrencyCode: currencySign) ?? "$")
        .font(.system(.title2, weight: .medium))
      TextField("", text: $amountValue)
        .font(.system(.largeTitle, weight: .medium))
        .tint(.clear)
        .multilineTextAlignment(.leading)
        .disabled(true)
      
      Spacer()
      
      Button {
        amountValue.removeLast()
        amountValue = Source.Functions.reformatTextValue(amountValue, addingCharacter: false)
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
    EXBaseCard {
      VStack(alignment: .leading) {
        Text(budgetValue.formattedAsCurrencySolid(with: currencySign))
          .font(.title3Semibold)
          .foregroundColor(.primaryGreen)
        Text("Funds needed for goal")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// MARK: - Validation
extension AddGoalTransactionView {
  func validate(completion: @escaping() -> Void) {
    if Double(amountValue.replacingOccurrences(of: ",", with: "")) != 0 {
      createGoalTransaction()
      completion()
    } else {
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
  }
}

// MARK: - Realm Functions
extension AddGoalTransactionView {
  func createGoalTransaction() {
    AnalyticsManager.shared.log(.addMoneyToGoal(Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0))
    goalTransaction.amount = Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0
    if let newGoal = goal.thaw(), let realm = newGoal.realm {
      try? realm.write {
        newGoal.currentAmount += Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0
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
