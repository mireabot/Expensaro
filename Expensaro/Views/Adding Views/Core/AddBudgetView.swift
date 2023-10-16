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
  @State private var budgetAmount: String = "0.0"
  
  // MARK: Presentation
  @State private var showError = false
  var body: some View {
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
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
            }
            .buttonStyle(EXPlainButtonStyle())
          }
          Text(type.infoText)
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
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
          Text(type.title)
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

struct AddBudgetView_Previews: PreviewProvider {
  static var previews: some View {
    AddBudgetView(type: .updateBudget, budget: Budget())
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

// MARK: - Realm Functions
extension AddBudgetView {
  /// Creates new copy of budget objects and saves in memory
  func addBudget() {
    budget.amount = Double(budgetAmount) ?? 0
    try? realm.write {
      realm.add(budget)
    }
  }
  
  /// Gets freezed copy of budget object and updates amount field
  func updateBudget() {
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += Double(budgetAmount) ?? 0
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
        return ""
      case .updateBudget:
        return "Enter amount which you want to add to your current budget"
      }
    }
  }
}

// MARK: - Validation
extension AddBudgetView {
  func validate(completion: @escaping() -> Void) {
    if Double(budgetAmount) != 0 {
      switch type {
      case .addBudget:
        addBudget()
      case .updateBudget:
        updateBudget()
      }
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
