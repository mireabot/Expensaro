//
//  AddDailyTransactionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/16/24.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct AddDailyTransactionView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var dailyTransaction: DailyTransaction
  
  // MARK: Variables
  @State var amountValue: String = "0.0"
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
          VStack(spacing: 15) {
            VStack(spacing: 10) {
              transactionTextField()
            }
            EXTextField(text: $dailyTransaction.name, header: "Daily transaction name", placeholder: Appearance.shared.textFieldDailyTransactionPlaceholder)
              .focused($isFieldFocused)
            Button(action: {
              showCategoriesSelector.toggle()
            }, label: {
              EXLargeSelector(text: $dailyTransaction.categoryName, icon: .constant(.imageName(dailyTransaction.categoryIcon)), header: "Category", rightIcon: "swipeDown")
            })
            .buttonStyle(EXPlainButtonStyle())
          }
          .padding(.top, 20)
        }
        .applyBounce()
        EXNumberKeyboard(textValue: $amountValue) {
          validateBudget()
        }
      })
      .ignoresSafeArea(.keyboard, edges: .all)
      .onTapGesture {
        isFieldFocused = false
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
        CategorySelectorView(presentation: $showCategoriesSelector, title: $dailyTransaction.categoryName, icon: $dailyTransaction.categoryIcon, section: $dailyTransaction.categorySection)
          .frame(height: 600)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
          .presentationDragIndicator(.visible)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.dailyTitle)
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

#Preview(body: {
  AddDailyTransactionView(dailyTransaction: DailyTransaction())
    .environment(\.realmConfiguration, RealmMigrator.configuration)
})

// MARK: - Apperance
extension AddDailyTransactionView {
  struct Appearance {
    static let shared = Appearance()
    let dailyTitle = "Add daily transaction"
    let textFieldDailyTransactionPlaceholder = "What did you spend money on?"
    
    let closeIcon = Source.Images.Navigation.close
  }
}

// MARK: - Realm Functions
extension AddDailyTransactionView {
  func createTransaction() {
    AnalyticsManager.shared.log(.dailyTransactionCreated(dailyTransaction.name))
    dailyTransaction.amount = Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0
    try? realm.write {
      realm.add(dailyTransaction)
    }
  }
}

// MARK: - Helper Views
extension AddDailyTransactionView {
  @ViewBuilder
  func transactionTextField() -> some View {
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
        if amountValue.isEmpty {
          amountValue = "0.0"
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
}

// MARK: - Helper Functions
extension AddDailyTransactionView {
  func validateBudget() {
    if Double(amountValue.replacingOccurrences(of: ",", with: "")) ?? 0 == 0 {
      errorType = .zeroAmount
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      return
    } else if dailyTransaction.name.isEmpty {
      errorType = .emptyName
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      return
    } else {
      createTransaction()
      makeDismiss()
    }
  }
  
  enum ScreenType {
    case regularTransaction
    case dailyTransaction
  }
}
