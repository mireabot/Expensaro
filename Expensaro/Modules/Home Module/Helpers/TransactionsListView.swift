//
//  TransactionsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct TransactionsListView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  
  @State private var showAddTransaction = false
  @State private var showTransactionDetail = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        headerView().padding(.top, 20)
        if groupedTransactions.isEmpty {
          EXEmptyStateView(type: .noTransactions, isCard: false).padding(.top, 30)
        } else {
          LazyVStack {
            ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
              Section(header: listHeader(date)) {
                ForEach(groupedTransactions[date]!) { transaction in
                  Button {
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionDetailView(transaction: transaction, budget: currentBudget)))
                  } label: {
                    EXTransactionCell(transaction: transaction)
                  }
                  .buttonStyle(EXPlainButtonStyle())
                }
              }
            }
          }
          .padding(.bottom, 10)
        }
      }
      .applyMargins()
      .fullScreenCover(isPresented: $showAddTransaction, content: {
        AddTransactionView(transaction: Transaction(), budget: currentBudget)
          .presentationDetents([.large])
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .foregroundColor(.black)
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showAddTransaction.toggle()
          } label: {
            Appearance.shared.addIcon
              .foregroundColor(.black)
          }
        }
      }
    }
  }
  
  @ViewBuilder
  func headerView() -> some View {
    HStack(alignment: .center, spacing: 35) {
      VStack(alignment: .center, spacing: 3) {
        Text("$\(currentBudget.amount.withDecimals)")
          .font(.system(.headline, weight: .semibold))
        Text("Budget left")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
      }
      Text("\(Source.Functions.currentMonth())")
        .font(.system(.title3, weight: .semibold))
      VStack(alignment: .center, spacing: 3) {
        Text("$\(totalSpent.withDecimals)")
          .font(.system(.headline, weight: .semibold))
        Text("Total spent")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(20)
    .background(Color.backgroundGrey)
    .cornerRadius(16)
  }
}

struct TransactionsListView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionsListView()
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Appearance
extension TransactionsListView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let backIcon = Source.Images.Navigation.back
    let addIcon = Source.Images.ButtonIcons.add
    
  }
}

// MARK: - Helper Functions
private extension TransactionsListView {
  var groupedTransactions: [Date: [Transaction]] {
    Dictionary(grouping: transactions.reversed()) { transaction in
      let calendar = Calendar.current
      return calendar.startOfDay(for: transaction.date)
    }
  }
  
  var currentBudget: Budget {
    budget.first ?? Budget()
  }
  
  var totalSpent: Double {
    var total: Double = 0
    for i in transactions.where({$0.categoryName != "Added funds"}) {
      total += i.amount
    }
    return total
  }
  
  @ViewBuilder
  func listHeader(_ date: Date) -> some View {
    Text(Source.Functions.showString(from: date))
      .font(.system(.subheadline, weight: .regular))
      .foregroundColor(.darkGrey)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
