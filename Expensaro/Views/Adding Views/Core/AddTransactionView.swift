//
//  AddTransactionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct AddTransactionView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  
  @Environment(\.realm) var realm
  @ObservedRealmObject var transaction: Transaction
  @ObservedRealmObject var budget: Budget
  
  @State private var showCategoriesSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $transaction.type, type: .transactionType).padding(.top, 16)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(value: $transaction.amount, bottomView: EmptyView()).focused($isFieldFocused)
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
      }
      .applyMargins()
      .sheet(isPresented: $showCategoriesSelector, content: {
        CategorySelectorView(title: $transaction.categoryName, icon: $transaction.categoryIcon)
          .presentationDetents([.medium,.fraction(0.9)])
          .presentationDragIndicator(.visible)
      })
      .safeAreaInset(edge: .bottom, content: {
        Button {
         createTransaction()
          makeDismiss()
        } label: {
          Text(Appearance.shared.buttonText)
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 15)
        .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
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
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.cameraIcon
              .font(.callout)
              .foregroundColor(.primaryGreen)
          }
        }
      }
    }
  }
}

struct AddTransactionView_Previews: PreviewProvider {
  static var previews: some View {
    AddTransactionView(transaction: Transaction(), budget: Budget())
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

extension AddTransactionView {
  func createTransaction() {
    let freezedBudget = self.budget.freeze()
    let copy = freezedBudget.thaw()
    
    try? realm.write {
      realm.add(transaction)
    }
    
    try? realm.write {
      copy?.amount -= transaction.amount
    }
  }
}
