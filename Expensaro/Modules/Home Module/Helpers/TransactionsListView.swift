//
//  TransactionsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import Algorithms

struct TransactionsListView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @AppStorage("currencySign") private var currencySign = "$"
  
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  
  @State private var showAddTransaction = false
  @State private var showTransactionDetail = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        headerView().padding(.top, 20)
        if chunkedTransactions.isEmpty {
          EXEmptyStateView(type: .noTransactions, isCard: false).padding(.top, 30)
        } else {
          LazyVStack(spacing: 10) {
            ForEach(chunkedTransactions, id: \.self) { transactions in
              Section {
                ForEach(transactions) { transaction in
                  Button {
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionDetailView(transaction: transaction, budget: currentBudget)))
                  } label: {
                    EXTransactionCell(transaction: transaction)
                  }
                  .buttonStyle(EXPlainButtonStyle())
                }
              } header: {
                listHeader(transactions.first!.date)
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
    EXBaseCard {
      HStack(alignment: .center, spacing: 30) {
        VStack(alignment: .center, spacing: 0) {
          Text("\(currencySign)\(currentBudget.amount.withDecimals)")
            .font(.headlineSemibold)
          Text("Budget left")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
        }
        Text("\(Source.Functions.currentMonth(date: .now))")
          .font(.title3Semibold)
        VStack(alignment: .center, spacing: 0) {
          Text("\(currencySign)\(totalSpent.withDecimals)")
            .font(.headlineSemibold)
          Text("Total spent")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
        }
      }
      .padding(4)
      .frame(maxWidth: .infinity, alignment: .center)
    }
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
  var chunkedTransactions: [[Transaction]] {
    let chunked = transactions.reversed().chunked {
      Calendar.current.isDate($0.date, equalTo: $1.date, toGranularity: .day)
    }
    return chunked.map { Array($0) }
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
