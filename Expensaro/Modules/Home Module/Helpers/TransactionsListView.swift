//
//  TransactionsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit

struct TransactionsListView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  @State private var showAddTransaction = false
  @State private var showTransactionDetail = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        headerView().padding(.top, 20)
        LazyVStack {
          ForEach(groupedTransactions.keys.sorted(by: <), id: \.self) { date in
            Section(header: listHeader(date)) {
              ForEach(groupedTransactions[date]!) { transaction in
                EXTransactionCell(transaction: transaction)
                  .onTapGesture {
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TransactionDetailView(transaction: transaction)))
                  }
              }
            }
          }
        }
      }
      .applyMargins()
      .sheet(isPresented: $showAddTransaction, content: {
        AddTransactionView()
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
        Text("$5,000")
          .font(.mukta(.semibold, size: 17))
        Text("Budget left")
          .font(.mukta(.regular, size: 15))
          .foregroundColor(.darkGrey)
      }
      Text("October")
        .font(.mukta(.semibold, size: 20))
      VStack(alignment: .center, spacing: -3) {
        Text("$1,677")
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
  }
}

// MARK: - Helper Functions
private extension TransactionsListView {
  var groupedTransactions: [Date: [Transaction]] {
    Dictionary(grouping: Transaction.sampleTransactions) { transaction in
      let calendar = Calendar.current
      return calendar.startOfDay(for: transaction.date)
    }
  }
  
  @ViewBuilder
  func listHeader(_ date: Date) -> some View {
    Text(Source.Functions.showString(from: date))
      .font(.mukta(.regular, size: 15))
      .foregroundColor(.darkGrey)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
