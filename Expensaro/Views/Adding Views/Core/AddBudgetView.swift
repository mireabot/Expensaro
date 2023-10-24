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
  
  // MARK: Presentation
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          VStack(alignment: .leading, spacing: 10) {
            budgetTextField()
            Text(type.infoText)
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
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
}

// MARK: - Realm Functions
extension AddBudgetView {
  /// Creates new copy of budget objects and saves in memory
  func addBudget() {
    budget.amount = Double(amountValue) ?? 0
    try? realm.write {
      realm.add(budget)
    }
  }
  
  /// Gets freezed copy of budget object and updates amount field
  func updateBudget() {
    let incomeTransaction = Source.Realm.createTransaction(name: "Budget top up", date: Date(), category: (Source.Strings.Categories.Images.income, "Added funds"), amount: Double(amountValue) ?? 0, type: "Refill")
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += Double(amountValue) ?? 0
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
  func validate(completion: @escaping() -> Void) {
    if Double(amountValue) != 0 {
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
}
