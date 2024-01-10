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
  @AppStorage("currencySign") private var currencySign = "$"
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var transaction: Transaction
  @ObservedRealmObject var budget: Budget
  var isUpdating: Bool {
    transaction.realm != nil
  }
  
  // MARK: Variables
  @State var amountValue: String = "0.0"
  @State private var budgetValue: Double = 0
  @State private var budgetExceed: Double = 0
  @State private var isBudgetAvailable = true
  @State private var isLoading = false
  
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Errors
  @State private var errorType = EXToasts.none
  
  // MARK: Presentation
  @State private var showCategoriesSelector = false
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          EXSegmentControl(currentTab: $transaction.type, type: .transactionType).padding(.top, 20)
          VStack(spacing: 15) {
            VStack(spacing: 10) {
              transactionTextField()
              budgetSection()
            }
            EXTextField(text: $transaction.name, header: "Transaction name", placeholder: Appearance.shared.textFieldPlaceholder)
              .autocorrectionDisabled()
              .focused($isFieldFocused)
            Button(action: {
              showCategoriesSelector.toggle()
            }, label: {
              EXLargeSelector(text: $transaction.categoryName, icon: .constant(.imageName(transaction.categoryIcon)), header: "Category", rightIcon: "swipeDown")
            })
            .buttonStyle(EXPlainButtonStyle())
          }
          .padding(.top, 20)
        }
        .applyBounce()
        EXNumberKeyboard(textValue: $amountValue) {
          if Double(amountValue) == transaction.amount && isUpdating {
            makeDismiss()
          }
          else {
            validateBudget()
          }
        }
      })
      .ignoresSafeArea(.keyboard, edges: .all)
      .onTapGesture {
        isFieldFocused = false
      }
      .onAppear {
        if isUpdating {
          amountValue = String(transaction.amount)
          budgetValue = budget.amount
        } else {
          budgetValue = budget.amount
        }
      }
      .applyMargins()
      .popup(isPresented: $showError, view: {
        EXToast(type: $errorType)
      }, customize: {
        $0
          .isOpaque(true)
          .type(.floater())
          .position(.top)
          .autohideIn(1.5)
      })
      .sheet(isPresented: $showCategoriesSelector) {
        CategorySelectorView(presentation: $showCategoriesSelector, title: $transaction.categoryName, icon: $transaction.categoryIcon, section: $transaction.categorySection)
          .frame(height: 600)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
          .presentationDragIndicator(.visible)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(isUpdating ? Appearance.shared.updateTitle : Appearance.shared.title)
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
    let title = "Add transaction"
    let updateTitle = "Edit transaction"
    let textFieldPlaceholder = "What did you spend money on?"
    
    let closeIcon = Source.Images.Navigation.close
    let cameraIcon = Source.Images.System.scan
  }
}

// MARK: - Realm Functions
extension AddTransactionView {
  func createTransaction() {
    AnalyticsManager.shared.log(.createTransaction)
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
  
  func updateTransaction() {
    AnalyticsManager.shared.log(.editTransaction)
    var difference: Double = 0
    if let newTransaction = transaction.thaw(), let realm = newTransaction.realm {
      try? realm.write {
        difference = newTransaction.amount - (Double(amountValue) ?? 0)
        newTransaction.amount = Double(amountValue) ?? 0
      }
    }
    print(difference)
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += difference
      }
    }
  }
}

// MARK: - Helper Views
extension AddTransactionView {
  @ViewBuilder
  func transactionTextField() -> some View {
    HStack {
      Text(currencySign)
        .font(.system(.title2, weight: .medium))
      TextField("", text: $amountValue)
        .font(.system(.largeTitle, weight: .medium))
        .tint(.clear)
        .multilineTextAlignment(.leading)
        .disabled(true)
      
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
    EXBaseCard {
      VStack(alignment: .leading) {
        Text("\(currencySign)\(budgetValue.clean)")
          .font(.title3Semibold)
          .foregroundColor(.primaryGreen)
        Text("Budget remaining")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
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
      if isUpdating {
        updateTransaction()
      } else {
        createTransaction()
      }
      makeDismiss()
    }
  }
}
