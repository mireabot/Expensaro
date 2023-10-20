//
//  AddTransactionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import Shimmer

struct AddTransactionView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  @FocusState private var budgetFieldFocused: Bool
  
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
  
  // MARK: Presentation
  @State private var showCategoriesSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $transaction.type, type: .transactionType).padding(.top, 16)
        VStack(spacing: 20) {
          VStack(spacing: 0) {
            transactionTextField()
            .inputView {
              EXNumberKeyboard(textValue: $amountValue) {
                validateBudget()
              }
              .applyMargins()
              .padding(.bottom, 15)
            }
            .focused($budgetFieldFocused)
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
      .onTapGesture {
        isFieldFocused = false
        budgetFieldFocused = false
      }
      .onAppear {
        budgetValue = budget.amount
      }
      .applyMargins()
      .sheet(isPresented: $showCategoriesSelector, content: {
        CategorySelectorView(title: $transaction.categoryName, icon: $transaction.categoryIcon)
          .presentationDetents([.medium,.fraction(0.9)])
          .presentationDragIndicator(.visible)
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
        ToolbarItem(placement: .bottomBar) {
          Button {
            createTransaction()
            makeDismiss()
          } label: {
            Text(Appearance.shared.buttonText)
              .font(.mukta(.semibold, size: 17))
          }
          .padding(.bottom, 15)
          .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
          .disabled(Double(amountValue) == 0 || transaction.name.isEmpty)
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
          budgetValue = budget.amount
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
      if isBudgetAvailable {
        Text("Budget available: $\(budgetValue.clean)")
          .font(.mukta(.medium, size: 17))
          .foregroundStyle(Color.primaryGreen)
          .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        Text("You exceed budget by: $\(budgetExceed.clean)")
          .font(.mukta(.medium, size: 17))
          .foregroundStyle(Color.red)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .shimmering(active: isLoading)
  }
}

// MARK: - Helper Functions
extension AddTransactionView {
  func validateBudget() {
    if amountValue != "0.0" {
      DispatchQueue.main.async {
        withAnimation(.smooth) {
          isLoading.toggle()
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        if Double(amountValue) ?? 0 > budgetValue {
          isBudgetAvailable = false
          budgetExceed = (Double(amountValue) ?? 0) - budgetValue
        } else {
          budgetValue -= Double(amountValue) ?? 0
        }
        isLoading.toggle()
      }
    } else {
      budgetFieldFocused = false
    }
  }
}
