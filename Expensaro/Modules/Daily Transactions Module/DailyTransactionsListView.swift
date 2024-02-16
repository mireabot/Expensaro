//
//  DailyTransactionsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/16/24.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct DailyTransactionsListView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @ObservedResults(DailyTransaction.self) var dailyTransactions
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Presentation
  @State private var showAddDailyTransactionScreen = false
  
  var body: some View {
    NavigationView {
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
        
        List {
          ForEach(dailyTransactions) { data in
            HStack {
              VStack(alignment: .leading, spacing: 0) {
                Text(data.name)
                  .font(.calloutSemibold)
                Text("\(data.amount.formattedAsCurrency(with: currencySign))")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
              }
              Spacer()
              Text(data.categoryIcon)
                .foregroundColor(.primaryGreen)
                .padding(10)
                .background(Color.backgroundGrey)
                .cornerRadius(8)
            }
              .listRowSeparator(.hidden)
          }
          .onDelete(perform: { indexSet in
            $dailyTransactions.remove(atOffsets: indexSet)
          })
        }
        .listStyle(.plain)
      }
      .fullScreenCover(isPresented: $showAddDailyTransactionScreen, content: {
        AddDailyTransactionView(dailyTransaction: DailyTransaction())
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.headlineMedium)
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
  
  @ViewBuilder
  func cell() -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text("Subway ride")
          .font(.calloutSemibold)
        Text("$2.90")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
      Spacer()
      Text("🏠")
        .foregroundColor(.primaryGreen)
        .padding(10)
        .background(Color.backgroundGrey)
        .cornerRadius(8)
    }
  }
}

#Preview {
  DailyTransactionsListView()
    .environment(\.realmConfiguration, RealmMigrator.configuration)
}
