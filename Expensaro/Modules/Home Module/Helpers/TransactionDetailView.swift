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
        // MARK: Transaction header
        VStack(alignment: .leading, spacing: 3) {
          Text(transaction.name)
            .font(.mukta(.medium, size: 20))
          Text("$\(transaction.amount.clean)")
            .font(.mukta(.bold, size: 34))
          Text(Source.Functions.showString(from: transaction.date))
            .font(.mukta(.regular, size: 15))
            .foregroundColor(.darkGrey)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        
        // MARK: Transaction detail
        VStack(spacing: 15) {
          HStack {
            transaction.category.0
              .foregroundColor(.primaryGreen)
              .padding(8)
              .background(Color.backgroundGrey)
              .cornerRadius(12)
            VStack(alignment: .leading, spacing: -3) {
              Text("Category")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text(transaction.category.1)
                .font(.mukta(.medium, size: 15))
                .foregroundColor(.black)
            }
            Spacer()
            Source.Images.ButtonIcons.selector
              .resizable()
              .frame(width: 20, height: 20)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .onTapGesture {
            // Select new category
          }
          HStack {
            Source.Images.System.transactionType
              .foregroundColor(.black)
              .padding(8)
            VStack(alignment: .leading, spacing: -3) {
              Text("Type")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
              Text(transaction.type)
                .font(.mukta(.medium, size: 15))
                .foregroundColor(.black)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(.white)
        .cornerRadius(12)
        .shadowXS()
        
        HStack {
          Source.Images.ButtonIcons.edit
            .padding(8)
          VStack(alignment: .leading, spacing: -3) {
            Text("Note")
              .font(.mukta(.regular, size: 15))
              .foregroundColor(.darkGrey)
            Text("Sample note text")
              .font(.mukta(.medium, size: 15))
              .foregroundColor(.black)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white)
        .cornerRadius(12)
        .shadowXS()
        
      }
      .applyMargins()
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
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.deleteIcon
              .foregroundColor(.red)
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
    let deleteIcon = Source.Images.ButtonIcons.delete
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
