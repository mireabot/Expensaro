//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import SwiftData
import PopupView

struct HomeView: View {
  // MARK: Navigation
  @Dependency(\.router) private var router
  
  // MARK: Variables
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Presentation
  @State private var showAlert = false
  @State private var showPaymentAnimation = false
  @State private var showTransactionAnimation = false
  
  // MARK: Storage
  @Query(Budget.thisMonth) private var budget: [Budget]
  @Query(Transaction.thisMonth) private var transactions: [Transaction]
  @Query(RecurringTransaction.byDueDate) private var recurringTransactions: [RecurringTransaction]
  
  var body: some View {
    // Add actions live in the tab bar accessory, see AccessoryContent
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        budgetSection()
        recurrentPaymentsRow()
        transactionsPreview()
      }
      .applyMargins()
      .padding(.top, 5)
    }
    .onFirstAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
        withAnimation(.smooth) {
          showPaymentAnimation.toggle()
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
        withAnimation(.smooth) {
          showTransactionAnimation.toggle()
        }
      }
    }
    .popup(isPresented: $showAlert, view: {
      EXToast(type: .constant(.zeroBudget))
    }, customize: {
      $0
        .isOpaque(true)
        .position(.top)
        .type(.floater())
        .autohideIn(1.5)
    })
    .rootNavigationTitle(Appearance.shared.title)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          router.navigate(to: .settings)
        } label: {
          Appearance.shared.settingsIcon
            .foregroundColor(.black)
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
      .modelContainer(AppModelStore.preview)
  }
}

// MARK: - Apperance
extension HomeView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Home"
    
    let settingsIcon = Source.Images.System.settings
  }
}

// MARK: - Helper Views
extension HomeView {
  var currentBudget: Budget {
    budget.first ?? Budget()
  }
}

// MARK: - Home screen sections views
extension HomeView {
  @ViewBuilder
  func budgetSection() -> some View {
    if let currentBudget = budget.first {
      VStack(alignment: .leading, spacing: 3) {
        Text("Your budget")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
        Text("\(currentBudget.amount.formattedAsCurrency(with: currencySign))")
          .font(.system(.largeTitle, weight: .bold))
          .foregroundColor(.black)
        
        Button {
          router.presentFullScreenCover(.updateBudget(currentBudget))
        } label: {
          HStack {
            Source.Images.ButtonIcons.add
              .foregroundColor(.primaryGreen)
            Text("Add money")
              .font(.system(.headline, weight: .semibold))
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(EXSmallButtonStyle())
        .padding(.top, 16)
      }
    } else {
      EXLargeEmptyState(config: (Source.Strings.EmptyStateType.noBudget.title,
                                 Source.Strings.EmptyStateType.noBudget.text,
                                 Source.Strings.EmptyStateType.noBudget.buttonText),
                        icon: Source.Images.EmptyStates.noBudget,
                        isActive: false,
                        action: {
        router.presentFullScreenCover(.addBudget)
      })
    }
  }
  
  @ViewBuilder
  func recurrentPaymentsRow() -> some View {
    if !recurringTransactions.isEmpty {
      VStack(spacing: 15) {
        HStack {
          Text("Recurring payments")
            .font(.system(.headline, weight: .semibold))
            .foregroundColor(.black)
          Spacer()
          Button(action: {
            router.navigate(to: .recurringPaymentsList(currentBudget))
          }) {
            Text("View all")
              .font(.system(.subheadline, weight: .semibold))
          }
          .buttonStyle(EXTextButtonStyle())
        }
        
        VStack {
          ZStack {
            if showPaymentAnimation {
              HStack {
                ForEach(recurringTransactions.prefix(2)) { payment in
                  Button {
                    router.navigate(to: .recurringPaymentDetail(payment, currentBudget))
                  } label: {
                    EXRecurringTransactionCell(payment: payment)
                  }
                  .buttonStyle(EXPlainButtonStyle())
                }
              }
              .transition(.move(edge: .trailing))
            } else {
              EXRecurringTransactionCellLoading()
            }
          }
          if recurringTransactions.count >= 3 {
            HStack {
              Text("+ \(checkPaymentDifference(recurringTransactions.count, comparator: 2))")
                .font(.system(.footnote, weight: .regular))
                .foregroundColor(.darkGrey)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(10)
            }
            .background(Color.backgroundGrey)
            .cornerRadius(5)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.top, 15)
    } else {
      EXSmallEmptyState(config: (Source.Strings.EmptyStateType.noRecurrentPayments.title,
                                 Source.Strings.EmptyStateType.noRecurrentPayments.text,
                                 Source.Strings.EmptyStateType.noRecurrentPayments.buttonText),
                        isActive: currentBudget.amount == 0,
                        action: {
        router.presentFullScreenCover(.addRecurringPayment(currentBudget))
      })
      .padding(.top, 15)
    }
  }
  
  @ViewBuilder
  func transactionsPreview() -> some View {
    if !transactions.isEmpty {
      VStack(spacing: 15) {
        HStack {
          VStack(alignment: .leading, spacing: 3) {
            Text("Spendings for")
              .font(.system(.subheadline, weight: .regular))
              .foregroundColor(.darkGrey)
            Text("\(Source.Functions.currentMonth(date: .now))")
              .font(.system(.title3, weight: .semibold))
          }
          Spacer()
          Button(action: {
            router.navigate(to: .transactionsList)
          }) {
            Text("View all")
              .font(.system(.subheadline, weight: .semibold))
          }
          .buttonStyle(EXTextButtonStyle())
        }
        ZStack {
          if showTransactionAnimation {
            VStack {
              ForEach(transactions.reversed().prefix(3)) { transaction in
                Button {
                  router.navigate(to: .transactionDetail(transaction, currentBudget))
                } label: {
                  EXTransactionCell(transaction: transaction)
                }
                .buttonStyle(EXPlainButtonStyle())
                .padding(.bottom, 5)
              }
              if transactions.count >= 4 {
                HStack {
                  Text("+ \(checkTransactionDifference(transactions.count, comparator: 3))")
                    .font(.system(.footnote, weight: .regular))
                    .foregroundColor(.darkGrey)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(10)
                }
                .background(Color.backgroundGrey)
                .cornerRadius(5)
              }
            }
            .padding(.bottom, 5)
            .transition(.move(edge: .bottom))
          } else {
            EXTransactionCellLoading()
          }
        }
      }
      .padding(.top, 15)
      .fixedSize(horizontal: false, vertical: true)
    } else {
      EXLargeEmptyState(config: (Source.Strings.EmptyStateType.noExpenses.title,
                                 Source.Strings.EmptyStateType.noExpenses.text,
                                 Source.Strings.EmptyStateType.noExpenses.buttonText),
                        icon: Source.Images.EmptyStates.noExpenses,
                        isActive: currentBudget.amount == 0,
                        action: {
        router.presentFullScreenCover(.addTransaction(currentBudget))
      })
      .padding(.top, 15)
    }
  }
}

// MARK: - Helper Functions
extension HomeView {
  func checkTransactionDifference(_ number: Int, comparator: Int) -> String {
    let difference = abs(number - comparator)
    
    if difference == 1 {
      return "1 transaction"
    } else {
      return "\(difference) transactions"
    }
  }
  
  func checkPaymentDifference(_ number: Int, comparator: Int) -> String {
    let difference = abs(number - comparator)
    
    if difference == 1 {
      return "1 recurring payment"
    } else {
      return "\(difference) recurring payments"
    }
  }
}
