//
//  TransactionDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/4/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import SwiftData

struct TransactionDetailView: View {
  // MARK: Essential
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Storage
  @Bindable var transaction: Transaction
  @Bindable var budget: Budget
  
  // MARK: Presentation
  @State private var showNoteView = false
  @State private var showAnalyticsDemo = false
  var body: some View {
    ScrollView(showsIndicators: false) {
      // MARK: Transaction header
      VStack(alignment: .leading, spacing: 3) {
        Text(transaction.name)
          .font(.title3Medium)
        if transaction.type == "Refill" {
          Text("+ \(transaction.amount.formattedAsCurrency(with: currencySign))")
            .font(.largeTitleBold)
            .foregroundStyle(Color.green)
        } else {
          Text("\(transaction.amount.formattedAsCurrency(with: currencySign))")
            .font(.largeTitleBold)
        }
        Text(Source.Functions.showString(from: transaction.date))
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 16)
      
      // MARK: Transaction info
      HStack(spacing: 5) {
        EXChip(icon: .imageName(transaction.categoryIcon), text: transaction.categoryName)
        EXChip(icon: .imageName(""), text: transaction.type)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 5)
      
      // MARK: Transaction detail
      VStack {
        Button {
          showNoteView.toggle()
        } label: {
          EXBaseCard {
            HStack {
              Source.Images.ButtonIcons.note
                .padding(8)
              VStack(alignment: .leading, spacing: 3) {
                Text("Note")
                  .font(.system(.footnote, weight: .regular))
                  .foregroundColor(.darkGrey)
                Text(transaction.note.isEmpty ? "Add note" : transaction.note)
                  .font(.system(.subheadline, weight: .medium))
                  .foregroundColor(.black)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .buttonStyle(EXPlainButtonStyle())
      }
      .padding(.top, 5)
      
      // MARK: Analytics
      if transaction.type == "Debit" || transaction.type == "Credit" {
        TransactionInsightsView(categoryName: transaction.categoryName)
      } 
      else if transaction.type == "Daily transaction" {
        DailyTransactionInsightsView()
      }
    }
    .scrollBounceBehavior(.basedOnSize)
    .applyMargins()
    .sheet(isPresented: $showNoteView, content: {
      noteView()
        .presentationDetents([.fraction(0.95)])
    })
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          router.back()
        } label: {
          Appearance.shared.closeIcon
            .foregroundColor(.black)
        }
      }
    }
  }
}


// MARK: - Appearance
extension TransactionDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let closeIcon = Source.Images.Navigation.back
    let dismissIcon = Source.Images.Navigation.close
    let deleteIcon = Source.Images.ButtonIcons.delete
  }
}

// MARK: - Helper Views
private extension TransactionDetailView {
  @ViewBuilder
  func noteView() -> some View {
    ScrollView {
      HStack {
        Text("Create note")
          .font(.title3Semibold)
        Spacer()
        Button {
          showNoteView.toggle()
        } label: {
          Appearance.shared.dismissIcon
            .foregroundColor(.black)
        }
      }
      .padding(.top, 20)
      EXResizableTextField(message: $transaction.note, characterLimit: 300)
        .multilineSubmitEnabled(for: $transaction.note)
      Button {
        showNoteView.toggle()
        AnalyticsManager.shared.log(.madeNote(transaction.note))
      } label: {
        Text("Add note")
          .font(.system(.headline, weight: .semibold))
      }
      .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
      .padding(.top, 20)
    }
    .applyMargins()
  }
}
