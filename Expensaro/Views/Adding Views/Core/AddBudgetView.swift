//
//  AddBudgetView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct AddBudgetView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  let type: ScreenType
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var budget: Budget
  
  // MARK: Variables
  @State private var amountValue: String = "0.0"
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Presentation
  @State private var showError = false
  @State private var confirmBudget = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          VStack(alignment: .leading, spacing: 10) {
            budgetTextField()
            EXBaseCard {
              Text(type.infoText)
                .font(.system(.footnote, weight: .regular))
                .foregroundColor(.darkGrey)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .padding(.top, 20)
        }
        .applyBounce()
        
        EXNumberKeyboard(textValue: $amountValue, submitAction: {
          validate(onCreationSuccess: {
            confirmBudget.toggle()
          }, onUpdateSuccess: {
            updateBudget()
            makeDismiss()
          })
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
      .popup(isPresented: $confirmBudget) {
        EXAlert<EmptyView>(config: (Source.Strings.AlertType.createBudget.title,
                         Source.Strings.AlertType.createBudget.subTitle,
                         Source.Strings.AlertType.createBudget.secondaryButtonText,
                         Source.Strings.AlertType.createBudget.primaryButtonText)) {
          addBudget()
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            confirmBudget.toggle()
            makeDismiss()
          })
        } secondaryAction: {
          confirmBudget.toggle()
        }
        .applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .position(.bottom)
          .type(.floater(useSafeAreaInset: true))
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .applyMargins()
      .scrollDisabled(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(type.title)
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

struct AddBudgetView_Previews: PreviewProvider {
  static var previews: some View {
    AddBudgetView(type: .addBudget, budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Apperance
extension AddBudgetView {
  struct Appearance {
    static let shared = Appearance()
    
    let closeIcon = Source.Images.Navigation.close
  }
}

// MARK: - Helper Views
extension AddBudgetView {
  @ViewBuilder
  func budgetTextField() -> some View {
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
}

// MARK: - Realm Functions
extension AddBudgetView {
  /// Creates new copy of budget objects and saves in memory
  func addBudget() {
    budget.amount = Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0
    budget.initialAmount = Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0
    AnalyticsManager.shared.log(.createdBudget(Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0, .now))
    try? realm.write {
      realm.add(budget)
    }
  }
  
  /// Gets freezed copy of budget object and updates amount field
  func updateBudget() {
    let incomeTransaction = Source.Realm.createTransaction(name: "Budget deposit", date: Date(), category: ("Added funds", "💵", .other), amount: Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0, type: "Refill", note: "")
    AnalyticsManager.shared.log(.updatedBudget(Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0))
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0
        realm.add(incomeTransaction)
      }
    }
  }
}

// MARK: - Helper Enum
extension AddBudgetView {
  enum ScreenType {
    case addBudget
    case updateBudget
    
    var title: String {
      switch self {
      case .addBudget:
        return "Add budget"
      case .updateBudget:
        return "Update your budget"
      }
    }
    
    var buttonText: String {
      switch self {
      case .addBudget:
        return "Add budget"
      case .updateBudget:
        return "Update budget"
      }
    }
    
    var infoText: String {
      switch self {
      case .addBudget:
        return "Enter amount which you plan to spend this month"
      case .updateBudget:
        return "Enter amount which you want to add to your current budget"
      }
    }
  }
}

// MARK: - Validation
extension AddBudgetView {
  func validate(onCreationSuccess: @escaping () -> Void, onUpdateSuccess: @escaping () -> Void) {
    if Double(amountValue.replacingOccurrences(of: ",", with: "")) != 0 {
      switch type {
      case .addBudget:
        onCreationSuccess()
      case .updateBudget:
        onUpdateSuccess()
      }
    } else {
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
  }
}
