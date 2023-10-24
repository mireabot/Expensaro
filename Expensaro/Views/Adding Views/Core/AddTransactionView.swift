//
//  AddTransactionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct AddTransactionView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var transaction: Transaction
  @ObservedRealmObject var budget: Budget
  
  // MARK: Variables
  @State var amountValue: String = "0.0"
  @State private var budgetValue: Double = 0
  @State private var budgetExceed: Double = 0
  @State private var isBudgetAvailable = true
  @State private var isLoading = false
  
  // MARK: Errors
  @State private var errorType = EXErrors.none
  
  // MARK: Presentation
  @State private var showCategoriesSelector = false
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          EXSegmentControl(currentTab: $transaction.type, type: .transactionType).padding(.top, 20)
          VStack(spacing: 15) {
            VStack(spacing: 0) {
              transactionTextField()
              budgetSection()
            }
            EXTextField(text: $transaction.name, placeholder: Appearance.shared.textFieldPlaceholder)
              .keyboardType(.alphabet)
              .focused($isFieldFocused)
            EXLargeSelector(text: $transaction.categoryName, icon: $transaction.categoryIcon, buttonText: "Change", action: {
              showCategoriesSelector.toggle()
            })
            Text(Appearance.shared.infoText)
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        EXNumberKeyboard(textValue: $amountValue) {
          validateBudget()
        }
      })
      .ignoresSafeArea(.keyboard, edges: .all)
      .onTapGesture {
        isFieldFocused = false
      }
      .onAppear {
        budgetValue = budget.amount
      }
      .applyMargins()
      .popup(isPresented: $showError, view: {
        EXErrorView(type: $errorType)
      }, customize: {
        $0
          .isOpaque(true)
          .type(.floater())
          .position(.top)
          .autohideIn(1.5)
      })
      .sheet(isPresented: $showCategoriesSelector, content: {
        CategorySelectorView(title: $transaction.categoryName, icon: $transaction.categoryIcon)
          .presentationDetents([.fraction(0.9)])
      })
      .navigationBarTitleDisplayMode(.inline)
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

struct AddTransactionView_Previews: PreviewProvider {
  static var previews: some View {
    AddTransactionView(transaction: Transaction(), budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Apperance
extension AddTransactionView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add Transaction"
    let buttonText = "Add transaction"
    let textFieldPlaceholder = "Ex. House Rent"
    let infoText = "For your convenience date of transaction will be today. You can change it anytime in transaction card"
    
    let closeIcon = Source.Images.Navigation.close
    let cameraIcon = Source.Images.System.scan
  }
}

// MARK: - Realm Functions
extension AddTransactionView {
  func createTransaction() {
    transaction.amount = Double(amountValue) ?? 0
    try? realm.write {
      realm.add(transaction)
    }
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount -= transaction.amount
      }
    }
  }
}

// MARK: - Helper Views
extension AddTransactionView {
  @ViewBuilder
  func transactionTextField() -> some View {
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
        if amountValue.isEmpty {
          amountValue = "0.0"
          isBudgetAvailable = true
        }
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
  func budgetSection() -> some View {
    HStack {
      Text("Budget available: $\(budgetValue.clean)")
        .font(.mukta(.medium, size: 17))
        .foregroundStyle(Color.primaryGreen)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// MARK: - Helper Functions
extension AddTransactionView {
  func validateBudget() {
    if Double(amountValue) ?? 0 > budgetValue {
      errorType = .budgetExceed
      showError.toggle()
      return
    } else if Double(amountValue) ?? 0 == 0 {
      errorType = .zeroAmount
      showError.toggle()
      return
    } else if transaction.name.isEmpty {
      errorType = .emptyName
      showError.toggle()
      return
    } else {
      createTransaction()
      makeDismiss()
    }
  }
}
