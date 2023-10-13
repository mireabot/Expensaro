//
//  AddBudgetView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct AddBudgetView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  let type: ScreenType
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var budget: Budget
  
  // MARK: Variables
  @FocusState private var budgetFieldFocused: Bool
  @State private var budgetValue: Double = 0
  @State var detentHeight: CGFloat = 0
  
  // MARK: Presentation
  @State private var showSuccess = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          switch type {
          case .addBudget:
            EXTextFieldWithCurrency(value: $budget.amount)
              .focused($budgetFieldFocused)
          case .updateBudget:
            EXTextFieldWithCurrency(value: $budgetValue)
              .focused($budgetFieldFocused)
          }
          Text(type.infoText)
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
        }
      }
      .onTapGesture {
        budgetFieldFocused = false
      }
      .onAppear {
        budgetFieldFocused = true
      }
      .applyMargins()
      .scrollDisabled(true)
      .sheet(isPresented: $showSuccess) {
        SuccessBottomAlert(type: .budgetAdded)
          .padding(35)
          .onDisappear {
            makeDismiss()
          }
          .readHeight()
          .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
              self.detentHeight = height
            }
          }
          .presentationDetents([.height(self.detentHeight)])
      }
      .safeAreaInset(edge: .bottom, content: {
        Button {
          switch type {
          case .addBudget:
            addBudget {
              showSuccess.toggle()
            }
          case .updateBudget:
            updateBudget {
              makeDismiss()
            }
          }
        } label: {
          Text(type.buttonText)
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 15)
        .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
        
      })
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
  func addBudget(completion: @escaping() -> Void) {
    try? realm.write {
      realm.add(budget)
    }
    completion()
  }
  
  /// Gets freezed copy of budget object and updates amount field
  func updateBudget(completion: @escaping() -> Void) {
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += budgetValue
      }
    }
    completion()
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
