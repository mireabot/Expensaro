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
  @Environment(\.dismiss) var makeDismiss
  let type: ScreenType
  
  @Environment(\.realm) var realm
  
  @ObservedRealmObject var budget: Budget
  
  @FocusState private var budgetFieldFocused: Bool
  @State private var budgetValue: String = ""
  @State var detentHeight: CGFloat = 0
  
  @State private var showSuccess = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          EXTextFieldWithCurrency(value: $budget.amount)
            .focused($budgetFieldFocused)
          Text(type.infoText)
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
        }
      }
      .onTapGesture {
        budgetFieldFocused = false
      }
      .onAppear {
        DispatchQueue.main.async {
          budgetFieldFocused = true
        }
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
          addBudget()
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
    AddBudgetView(type: .addToGoal, budget: Budget())
  }
}

// MARK: - Apperance
extension AddBudgetView {
  struct Appearance {
    static let shared = Appearance()
    
    let closeIcon = Source.Images.Navigation.close
  }
}

// MARK: - Helper Enum
extension AddBudgetView {
  enum ScreenType {
    case addBudget
    case updateBudget
    case addToGoal
    
    var title: String {
      switch self {
      case .addBudget:
        return "Add budget"
      case .updateBudget:
        return "Update your budget"
      case .addToGoal:
        return "Add money towards goal"
      }
    }
    
    var buttonText: String {
      switch self {
      case .addBudget:
        return "Add budget"
      case .updateBudget:
        return "Update budget"
      case .addToGoal:
        return "Add money"
      }
    }
    
    var infoText: String {
      switch self {
      case .addBudget:
        return ""
      case .updateBudget:
        return "Enter amount which you want to add to your current budget"
      case .addToGoal:
        return ""
      }
    }
  }
}

// MARK: - Realm Functions
extension AddBudgetView {
  func addBudget() {
    try? realm.write {
      realm.add(budget)
    }
  }
}
