//
//  TransactionDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/4/23.
//

import SwiftUI
import ExpensaroUIKit

struct TransactionDetailView: View {
  @Environment(\.dismiss) var makeDismiss
  let transaction: Transaction
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            VStack(alignment: .leading, spacing: 0) {
              Text("$\(transaction.amount.clean)")
                .font(.mukta(.bold, size: 30))
              Text(transaction.name)
                .font(.mukta(.medium, size: 20))
            }
            Spacer()
            transaction.category.0
              .resizable()
              .frame(width: 35, height: 35)
              .foregroundColor(.primaryGreen)
              .padding(16)
              .background(Color.backgroundGrey)
              .cornerRadius(32)
          }
          Text(showTransactionDate(from: transaction.date))
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
          HStack(spacing: 25) {
            smallInfoView(title: "Category", text: transaction.category.1)
            smallInfoView(title: "Type", text: transaction.type)
          }
          .padding(.top, 15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .applyMargins()
        .padding(.top, 10)
      }
      .safeAreaInset(edge: .bottom, content: {
        bottomActionButton()
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding(16)
      })
      .scrollDisabled(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

struct TransactionDetailView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionDetailView(transaction: Transaction.sampleTransactions[1])
  }
}

// MARK: - Appearance
extension TransactionDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let closeIcon = Source.Images.Navigation.back
  }
}

// MARK: - Helper Functions
private extension TransactionDetailView {
   func showTransactionDate(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d, yyyy"
    return formatter.string(from: date)
  }
  
  @ViewBuilder
  func smallInfoView(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: -3) {
      Text(title)
        .font(.mukta(.regular, size: 15))
        .foregroundColor(.darkGrey)
      Text(text)
        .font(.mukta(.regular, size: 17))
    }
  }
  
  @ViewBuilder
  func bottomActionButton() -> some View {
    VStack {
      Menu {
        Button(action: {  }) {
          Label("Edit transaction", image: "buttonEdit")
        }
        
        Button(role: .destructive, action: {}) {
          Label("Delete transaction", image: "buttonDelete")
        }
        
      } label: {
        Source.Images.Navigation.menu
          .foregroundColor(.primaryGreen)
          .padding(20)
          .background(Color.secondaryYellow)
          .cornerRadius(40)
      }
      .font(.mukta(.regular, size: 15))
      .menuOrder(.fixed)
    }
  }
}
