//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct HomeView: View {
  // MARK: Navigation
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // MARK: Variables
  @State private var showAddBudget = false
  @State private var showAddRecurrentPayment = false
  @State private var showAddTransaction = false
  
  // MARK: Presentation
  @State private var showUpdateBudget = false
  @State private var showAlert = false
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  @ObservedResults(RecurringTransaction.self, sortDescriptor: SortDescriptor(keyPath: \RecurringTransaction.dueDate, ascending: true)) var recurringTransactions
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
          .padding(.top, 20)
        }
        bottomActionButton()
          .padding(16)
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
          .presentationDetents([.large])
      })
      .fullScreenCover(isPresented: $showAddTransaction, content: {
        AddTransactionView(transaction: Transaction(), budget: currentBudget)
          .presentationDetents([.large])
      })
      .fullScreenCover(isPresented: $showAddRecurrentPayment, content: {
        AddRecurrentPaymentView(recurringPayment: RecurringTransaction(), budget: currentBudget)
          .presentationDetents([.large])
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text(Appearance.shared.title)
            .font(.system(.title2, weight: .semibold))
        }
        
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
      .environment(\.realmConfiguration, RealmMigrator.configuration)
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
    if currentBudget.amount != 0, !transactions.isEmpty {
      VStack {
        Menu {
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
}

// MARK: - Home screen sections views
extension HomeView {
  @ViewBuilder
  func budgetSection() -> some View {
    if let currentBudget = budget.first {
      VStack(alignment: .leading, spacing: 5) {
        Text("Your budget")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
        Text("$\(currentBudget.amount.withDecimals)")
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
      EXLargeEmptyState(type: .noBudget, icon: Source.Images.EmptyStates.noBudget, action: {
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
      }
      .padding(.top, 15)
    } else {
      EXSmallEmptyState(type: .noRecurrentPayments, action: {
        if currentBudget.amount == 0 {
          showAlert.toggle()
        } else {
          showAddRecurrentPayment.toggle()
        }
      })
      .padding(.top, 15)
    }
  }
  
  @ViewBuilder
  func transactionsPreview() -> some View {
    if !transactions.isEmpty {
      VStack(spacing: 15) {
        HStack {
          VStack(alignment: .leading, spacing: 5) {
            Text("Spendings for")
              .font(.system(.subheadline, weight: .regular))
              .foregroundColor(.darkGrey)
            Text("\(Source.Functions.currentMonth())")
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
      }
      .padding(.top, 15)
    } else {
      EXLargeEmptyState(type: .noExpenses, icon: Source.Images.EmptyStates.noExpenses, action: {
        if currentBudget.amount == 0 {
          showAlert.toggle()
        } else {
          showAddTransaction.toggle()
        }
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
