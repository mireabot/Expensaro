//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftData
import PopupView

struct HomeView: View {
  // MARK: Navigation
  @EnvironmentObject var router: EXNavigationViewsRouter
  @EnvironmentObject var quickActions: HomeQuickActionsCoordinator
  
  // MARK: Variables
  @State private var showAddBudget = false
  @State private var showAddRecurrentPayment = false
  @State private var showAddTransaction = false
  @State private var showAddDailyTransaction = false
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Presentation
  @State private var showUpdateBudget = false
  @State private var showAlert = false
  @State private var showPaymentAnimation = false
  @State private var showTransactionAnimation = false
  
  // MARK: Storage
  @Query(Budget.thisMonth) private var budget: [Budget]
  @Query(Transaction.thisMonth) private var transactions: [Transaction]
  @Query(RecurringTransaction.byDueDate) private var recurringTransactions: [RecurringTransaction]
  @Query(DailyTransaction.byDateCreated) private var dailyTransactions: [DailyTransaction]
  
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        ScrollView(.vertical, showsIndicators: false) {
          VStack {
            budgetSection()
            recurrentPaymentsRow()
            transactionsPreview()
          }
          .applyMargins()
          .padding(.top, 5)
        }
        // iOS 26: actions live in the tab bar's side button, see HomeQuickActionsMenu
        if #unavailable(iOS 26.0) {
          bottomActionButton()
            .padding(16)
        }
      }
      .onChange(of: canAddTransactions, initial: true) { _, canAdd in
        quickActions.isAvailable = canAdd
      }
      .onChange(of: quickActions.pendingAction) { _, action in
        guard let action else { return }
        quickActions.pendingAction = nil
        handleQuickAction(action)
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
      .fullScreenCover(isPresented: $showAddBudget, content: {
        AddBudgetView(type: .addBudget, budget: Budget())
      })
      .fullScreenCover(isPresented: $showAddTransaction, content: {
        AddTransactionView(transaction: Transaction(), budget: currentBudget)
      })
      .fullScreenCover(isPresented: $showAddRecurrentPayment, content: {
        AddRecurrentPaymentView(recurringPayment: RecurringTransaction(), budget: currentBudget)
      })
      .fullScreenCover(isPresented: $showAddDailyTransaction, content: {
        DailyTransactionsListView()
      })
      .rootNavigationTitle(Appearance.shared.title)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(SettingsView()))
          } label: {
            Appearance.shared.settingsIcon
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
      .environmentObject(HomeQuickActionsCoordinator())
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
  @ViewBuilder
  func bottomActionButton() -> some View {
    if canAddTransactions {
      VStack {
        Menu {
          Menu("Daily Transactions") {
            ForEach(dailyTransactions) { dailyTransaction in
              Button(action: {
                addDailyTransaction(with: dailyTransaction)
              }) {
                Label("\(dailyTransaction.categoryIcon) \(dailyTransaction.name)", systemImage: "")
              }
            }
            // Add button for FT
            Button(action: { showAddDailyTransaction.toggle() }) {
              Label("Manage daily transactions", systemImage: "plus")
            }
          }
          .menuOrder(.priority)
          Button(action: { showAddTransaction.toggle() }) {
            Label("Add transaction", image: "buttonTransaction")
          }
          
          Button(action: { showAddRecurrentPayment.toggle() }) {
            Label("Add recurring payment", image: "buttonRecurrent")
          }
          
        } label: {
          ZStack {
            Circle()
              .fill(Color.secondaryYellow)
              .frame(width: 60, height: 60)
            Source.Images.ButtonIcons.add
              .foregroundColor(.primaryGreen)
          }
        }
        .font(.system(.subheadline, weight: .regular))
        .menuOrder(.fixed)
      }
    }
  }
  
  var currentBudget: Budget {
    budget.first ?? Budget()
  }
  
  var canAddTransactions: Bool {
    currentBudget.amount != 0 && !transactions.isEmpty
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
          showUpdateBudget.toggle()
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
      .fullScreenCover(isPresented: $showUpdateBudget) {
        AddBudgetView(type: .updateBudget, budget: currentBudget)
          .presentationDetents([.large])
      }
    } else {
      EXLargeEmptyState(config: (Source.Strings.EmptyStateType.noBudget.title,
                                 Source.Strings.EmptyStateType.noBudget.text,
                                 Source.Strings.EmptyStateType.noBudget.buttonText),
                        icon: Source.Images.EmptyStates.noBudget,
                        isActive: false,
                        action: {
        showAddBudget.toggle()
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
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentsListView(budget: currentBudget)))
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
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentDetailView(transaction: payment, budget: currentBudget)))
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
        showAddRecurrentPayment.toggle()
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
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionsListView()))
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
                  router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionDetailView(transaction: transaction, budget: currentBudget)))
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
        showAddTransaction.toggle()
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

// MARK: - Quick Actions
extension HomeView {
  func handleQuickAction(_ action: HomeQuickAction) {
    switch action {
    case .addTransaction:
      showAddTransaction.toggle()
    case .addRecurringPayment:
      showAddRecurrentPayment.toggle()
    case .manageDailyTransactions:
      showAddDailyTransaction.toggle()
    case .addDailyTransaction(let dailyTransaction):
      addDailyTransaction(with: dailyTransaction)
    }
  }
}

// MARK: - Storage Functions
extension HomeView {
  func addDailyTransaction(with dailyTransaction: DailyTransaction) {
    guard (try? dailyTransaction.spend(from: currentBudget)) == true else { return }
    AnalyticsManager.shared.log(.dailyTransactionUsed)
  }
}
