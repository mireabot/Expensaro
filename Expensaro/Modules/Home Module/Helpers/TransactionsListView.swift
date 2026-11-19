//
//  TransactionsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import SwiftData
import Algorithms

struct TransactionsListView: View {
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  @Query(Transaction.thisMonth) private var transactions: [Transaction]
  @Query(Budget.thisMonth) private var budget: [Budget]
  
  @State private var showTransactionDetail = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      if chunkedTransactions.isEmpty {
        EXEmptyStateView(type: .noTransactions, isCard: false).padding(.top, 30)
      } else {
        LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
          Section {
            LazyVStack(spacing: 10) {
              ForEach(chunkedTransactions, id: \.self) { transactions in
                Section {
                  ForEach(transactions) { transaction in
                    Button {
                      router.navigate(to: .transactionDetail(transaction, currentBudget))
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
            .applyMargins()
          } header: {
            headerView()
          }
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          router.back()
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
          router.presentFullScreenCover(for: .addTransaction(currentBudget))
        } label: {
          Appearance.shared.addIcon
            .foregroundColor(.black)
        }
      }
    }
  }
  
  @ViewBuilder
  func headerView() -> some View {
    EXBaseCard {
      HStack(alignment: .center, spacing: 30) {
        VStack(alignment: .center, spacing: 0) {
          Text("\(currentBudget.amount.formattedAsCurrency(with: currencySign))")
            .font(.headlineSemibold)
          Text("Budget left")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
        }
        Text("\(Source.Functions.currentMonth(date: .now))")
          .font(.title3Semibold)
        VStack(alignment: .center, spacing: 0) {
          Text("\(totalSpent.formattedAsCurrency(with: currencySign))")
            .font(.headlineSemibold)
          Text("Total spent")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
        }
      }
      .padding(4)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding(.vertical, 10)
    .padding(.horizontal, 16)
    .background(Color.white)
  }
}

struct TransactionsListView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionsListView()
      .modelContainer(AppModelStore.preview)
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
    let chunked = transactions.sorted(by: { $0.date > $1.date }).chunked {
      Calendar.current.isDate($0.date, equalTo: $1.date, toGranularity: .day)
    }
    return chunked.map { Array($0) }
  }
  
  var currentBudget: Budget {
    budget.first ?? Budget()
  }
  
  var totalSpent: Double {
    var total: Double = 0
    return transactions.spendings.totalAmount
  }
  
  @ViewBuilder
  func listHeader(_ date: Date) -> some View {
    Text(Source.Functions.showString(from: date))
      .font(.system(.subheadline, weight: .regular))
      .foregroundColor(.darkGrey)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
