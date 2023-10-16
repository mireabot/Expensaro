//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct HomeView: View {
  // Navigation
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // Variables
  @State private var showAddBudget = false
  @State private var showAddRecurrentPayment = false
  @State private var showAddTransaction = false
  
  // Presentation
  @State private var showUpdateBudget = false
  
  // Realm
  @Environment(\.realm) var realm
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  @ObservedResults(Transaction.self) var transactions
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

// MARK: Home screen sections views
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
            //router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentsListView()))
          }) {
            Text("See all")
              .font(.mukta(.semibold, size: 15))
          }
          .buttonStyle(TextButtonStyle())
        }
        HStack {
          ForEach(recurringTransactions.prefix(3)) { payment in
            Button {
              //router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentDetailView(payment: payment)))
            } label: {
              EXRecurringTransactionCell(transaction: payment)
            }
            .buttonStyle(EXPlainButtonStyle())
          }
        }
      }
    } else {
      EXSmallEmptyState(type: .noRecurrentPayments, action: {
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
          VStack(alignment: .leading, spacing: -3) {
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
              .font(.mukta(.medium, size: 15))
          }
          .buttonStyle(SmallButtonStyle())
        }
        Divider()
        VStack {
          ForEach(transactions.prefix(3)) { transaction in
            EXTransactionCell(transaction: transaction)
          }
        }
        .padding(.bottom, 5)
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 10)
      .background(.white)
      .cornerRadius(10)
      .shadowXS()
      .padding(.top, 10)
    } else {
      EXLargeEmptyState(type: .noExpenses, icon: Source.Images.EmptyStates.noExpenses, action: {
        showAddTransaction.toggle()
      })
      .padding(.top, 15)
    }
  }
}
