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
  @State private var showRenewView = false
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  @ObservedResults(RecurringTransaction.self, sortDescriptor: SortDescriptor(keyPath: \RecurringTransaction.dueDate, ascending: true)) var recurringTransactions
  @ObservedResults(RecurringTransaction.self, filter: NSPredicate(format: "dueDate >= %@ AND dueDate < %@", Calendar.current.date(byAdding: .day, value: 0, to: Date())! as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: Date())! as NSDate)) var renewingPayments
  @ObservedResults(Category.self, sortDescriptor: SortDescriptor(keyPath: \Category.name, ascending: true)) var categories
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
      .onFirstAppear {
        compareAndMergeArrays(array1: categories.toArray(), realm: realm)
        if renewingPayments.count != 0 {
          showRenewView.toggle()
        }
      }
      .popup(isPresented: $showAlert, view: {
        EXErrorView(type: .constant(.zeroBudget))
      }, customize: {
        $0
          .isOpaque(true)
          .position(.top)
          .type(.floater())
          .autohideIn(1.5)
      })
      .sheet(isPresented: $showRenewView, content: {
        RecurringPaymentsRenewView(budget: currentBudget)
          .presentationDetents([.medium])
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
            .font(.mukta(.medium, size: 24))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(SettingsView()))
          } label: {
            Appearance.shared.settingsIcon
              .foregroundColor(.primaryGreen)
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
        .font(.mukta(.regular, size: 15))
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
      VStack(alignment: .center, spacing: -5) {
        Text("Your budget")
          .font(.mukta(.regular, size: 17))
          .foregroundColor(.darkGrey)
        Text("$ \(currentBudget.amount, specifier: "%.2f")")
          .font(.mukta(.bold, size: 34))
          .foregroundColor(.black)
        
        Button {
          showUpdateBudget.toggle()
        } label: {
          HStack {
            Source.Images.ButtonIcons.add
              .foregroundColor(.primaryGreen)
            Text("Add money")
              .font(.mukta(.semibold, size: 15))
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(SmallButtonStyle())
        .padding(.top, 20)
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
            .font(.mukta(.semibold, size: 17))
            .foregroundColor(.black)
          Spacer()
          Button(action: {
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentsListView(budget: currentBudget)))
          }) {
            Text("See all")
              .font(.mukta(.semibold, size: 15))
          }
          .buttonStyle(TextButtonStyle())
        }
        
        VStack {
          ForEach(recurringTransactions.prefix(1)) { payment in
            Button {
              router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentDetailView(transaction: payment, budget: currentBudget)))
            } label: {
              EXRecurringTransactionCell(transaction: payment)
            }
            .buttonStyle(EXPlainButtonStyle())
            
            if recurringTransactions.count >= 2 {
              HStack {
                Text("+ \(recurringTransactions.count - 1) recurring payments")
                  .font(.mukta(.regular, size: 13))
                  .foregroundColor(.darkGrey)
                  .frame(maxWidth: .infinity, alignment: .center)
                  .padding(5)
              }
              .background(Color.backgroundGrey)
              .cornerRadius(5)
            }
          }
        }
      }
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
          VStack(alignment: .leading, spacing: -5) {
            Text("Spendings for")
              .font(.mukta(.regular, size: 15))
              .foregroundColor(.darkGrey)
            Text("\(Source.Functions.currentMonth())")
              .font(.mukta(.semibold, size: 20))
          }
          Spacer()
          Button(action: {
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionsListView()))
          }) {
            Text("See all")
              .font(.mukta(.semibold, size: 15))
          }
          .buttonStyle(TextButtonStyle())
        }
        VStack {
          ForEach(transactions.reversed().prefix(3)) { transaction in
            Button {
              router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionDetailView(transaction: transaction, budget: currentBudget)))
            } label: {
              EXTransactionCell(transaction: transaction)
            }
            .buttonStyle(EXPlainButtonStyle())
          }
          if transactions.count >= 4 {
            HStack {
              Text("+ \(transactions.count - 3) transactions")
                .font(.mukta(.regular, size: 13))
                .foregroundColor(.darkGrey)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(5)
            }
            .background(Color.backgroundGrey)
            .cornerRadius(5)
          }
        }
        .padding(.bottom, 5)
      }
      .padding(.top, 10)
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
