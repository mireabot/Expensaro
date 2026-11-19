//
//  DailyTransactionsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/16/24.
//

import SwiftUI
import ExpensaroUIKit
import SwiftData

struct DailyTransactionsListView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @Query(DailyTransaction.byDateCreated) private var dailyTransactions: [DailyTransaction]
  @AppStorage("currencySign") private var currencySign = "USD"
  @AppStorage("dailyTransactionsONB") private var isShownOnboarding = false
  
  // MARK: Presentation
  @State private var showAddDailyTransactionScreen = false
  @State private var showOnboarding = false
  
  var body: some View {
    NavigationStack {
      VStack {
        Button(action: {
          showAddDailyTransactionScreen.toggle()
        }, label: {
          Text("Create daily transaction")
            .font(.subheadlineMedium)
        })
        .buttonStyle(EXStretchButtonStyle(icon: Appearance.shared.addIcon))
        .padding(.top, 16)
        .applyMargins()
        
        ZStack {
          if dailyTransactions.isEmpty {
            VStack {
              EXEmptyStateView(type: .noDailyTransactions, isCard: false)
              Spacer()
            }
            .padding(16)
          } else {
            List {
              ForEach(dailyTransactions) { data in
                dailyTransactionCell(withName: data.name, amount: data.amount, icon: data.categoryIcon)
                  .listRowSeparator(.hidden)
              }
              .onDelete(perform: { indexSet in
                indexSet.map { dailyTransactions[$0] }.forEach { try? $0.delete() }
                AnalyticsManager.shared.log(.dailyTransactionDeleted)
              })
            }
            .listStyle(.plain)
          }
        }
      }
      .fullScreenCover(isPresented: $showAddDailyTransactionScreen, content: {
        AddDailyTransactionView(dailyTransaction: DailyTransaction())
      })
      .sheet(isPresented: $showOnboarding, content: {
        DailyTransactionsOnboarding()
          .presentationDetents([.large])
      })
      .onFirstAppear {
        if !isShownOnboarding {
          showOnboarding.toggle()
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.headlineMedium)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showOnboarding.toggle()
          } label: {
            Image(systemName: "questionmark.circle")
              .font(.footnoteRegular)
              .foregroundStyle(.black)
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .foregroundStyle(.black)
          }
        }
      }
    }
  }
}

extension DailyTransactionsListView {
  struct Appearance {
    static let shared = Appearance()
    
    let closeIcon = Source.Images.Navigation.close
    let addIcon = Source.Images.ButtonIcons.add
    let title = "Daily Transactions"
  }
}

#Preview {
  DailyTransactionsListView()
    .modelContainer(AppModelStore.preview)
}

extension DailyTransactionsListView {
  @ViewBuilder
  func dailyTransactionCell(withName name: String, amount: Double, icon: String) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(name)
          .font(.calloutSemibold)
        Text("\(amount.formattedAsCurrency(with: currencySign))")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
      Spacer()
      Text(icon)
        .foregroundColor(.primaryGreen)
        .padding(10)
        .background(Color.backgroundGrey)
        .cornerRadius(8)
    }
  }
}
