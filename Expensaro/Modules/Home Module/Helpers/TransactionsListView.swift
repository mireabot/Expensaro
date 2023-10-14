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
  
  @ObservedResults(Transaction.self) var transactions
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  
  @State private var showAddTransaction = false
  @State private var showTransactionDetail = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        headerView().padding(.top, 20)
        if groupedTransactions.isEmpty {
          Appearance.shared.emptyState()
        } else {
          LazyVStack {
            ForEach(groupedTransactions.keys.sorted(by: <), id: \.self) { date in
              Section(header: listHeader(date)) {
                ForEach(groupedTransactions[date]!) { transaction in
                  Button {
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionDetailView(transaction: transaction)))
                  } label: {
                    EXTransactionCell(transaction: transaction)
                  }
                  .buttonStyle(EXPlainButtonStyle())
                }
              }
            }
          }
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
            .font(.mukta(.medium, size: 17))
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
      VStack(alignment: .center, spacing: -3) {
        Text("$\(currentBudget.amount.clean)")
          .font(.mukta(.semibold, size: 17))
        Text("Budget left")
          .font(.mukta(.regular, size: 15))
          .foregroundColor(.darkGrey)
      }
      Text("October")
        .font(.mukta(.semibold, size: 20))
      VStack(alignment: .center, spacing: -3) {
        Text("$\(totalSpent.clean)")
          .font(.mukta(.semibold, size: 17))
        Text("Total spent")
          .font(.mukta(.regular, size: 15))
          .foregroundColor(.darkGrey)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(20)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}

struct TransactionsListView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionsListView()
  }
}

// MARK: - Appearance
extension TransactionsListView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let backIcon = Source.Images.Navigation.back
    let addIcon = Source.Images.ButtonIcons.add
    
    @ViewBuilder
    func emptyState() -> some View {
      VStack(alignment: .center, spacing: 5) {
        Source.Images.EmptyStates.noTransactions
          .resizable()
          .frame(width: 120, height: 120)
        VStack(spacing: 0) {
          Text("You have no transactions")
            .font(.mukta(.semibold, size: 20))
          Text("Create a new one with plus icon on the top")
            .font(.mukta(.regular, size: 17))
            .foregroundColor(.darkGrey)
        }
      }
      .padding(.top, 30)
    }
  }
}

// MARK: - Helper Functions
private extension TransactionsListView {
  var groupedTransactions: [Date: [Transaction]] {
    Dictionary(grouping: transactions) { transaction in
      let calendar = Calendar.current
      return calendar.startOfDay(for: transaction.date)
    }
  }
  
  var currentBudget: Budget {
    budget.first ?? Budget()
  }
  
  var totalSpent: Double {
    var total: Double = 0
    for i in transactions {
      total += i.amount
    }
    return total
  }
  
  @ViewBuilder
  func listHeader(_ date: Date) -> some View {
    Text(Source.Functions.showString(from: date))
      .font(.mukta(.regular, size: 15))
      .foregroundColor(.darkGrey)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
