//
//  TransactionDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/4/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView
import RealmSwift

struct TransactionDetailView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // MARK: Realm
  @ObservedRealmObject var transaction: Transaction
  @ObservedRealmObject var budget: Budget
  
  // MARK: Presentation
  @State private var showTransactionDeleteAlert = false
  @State private var showEditTransaction = false
  @State private var showNoteView = false
  @State private var showAnalyticsDemo = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing, content: {
        ScrollView(showsIndicators: false) {
          // MARK: Transaction header
          VStack(alignment: .leading, spacing: 3) {
            Text(transaction.name)
              .font(.title3Medium)
            if transaction.type == "Refill" {
              Text("+ $\(transaction.amount.withDecimals)")
                .font(.largeTitleBold)
                .foregroundStyle(Color.green)
            } else {
              Text("$\(transaction.amount.withDecimals)")
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
            EXChip(icon: transaction.categoryIcon, text: transaction.categoryName)
            EXChip(icon: "transactionType", text: transaction.type)
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
          if transaction.type != "Refill" {
            //TransactionInsightsDemoView()
            Button(action: {
              showAnalyticsDemo.toggle()
            }, label: {
              EXEmptyStateView(type: .noTransactionInsights, isActive: true)
            })
            .buttonStyle(EXPlainButtonStyle())
              .padding([.top, .bottom], 5)
          }
        }
        .applyBounce()
        bottomActionButton()
          .padding(.bottom, 16)
      })
      .applyMargins()
      .popup(isPresented: $showTransactionDeleteAlert) {
        EXAlert(type: .deleteTransaction, primaryAction: { deleteTransaction() }, secondaryAction: {showTransactionDeleteAlert.toggle()}).applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .position(.bottom)
          .type(.floater(useSafeAreaInset: true))
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .fullScreenCover(isPresented: $showEditTransaction, content: {
        AddTransactionView(transaction: transaction, budget: budget)
      })
      .sheet(isPresented: $showNoteView, content: {
        noteView()
          .presentationDetents([.fraction(0.95)])
      })
      .sheet(isPresented: $showAnalyticsDemo, content: {
        EXBottomInfoView(type: .transactions, action: {}, bottomView: {
          TransactionInsightsDemoView()
        })
        .applyMargins()
        .presentationDetents([.fraction(0.45)])
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.closeIcon
              .foregroundColor(.black)
          }
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
        .autocorrectionDisabled()
        .multilineSubmitEnabled(for: $transaction.note)
      Button {
        showNoteView.toggle()
      } label: {
        Text("Add note")
          .font(.system(.headline, weight: .semibold))
      }
      .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
      .padding(.top, 20)
    }
    .applyMargins()
  }
  
  @ViewBuilder
  func bottomActionButton() -> some View {
    VStack {
      Menu {
        if transaction.type != "Refill" {
          Button(action: { showEditTransaction.toggle() }) {
            Label("Edit transaction", image: "buttonEdit")
          }
        }
        
        if transaction.note.isEmpty {
          Button(action: { showNoteView.toggle() }) {
            Label("Create note", image: "buttonNote")
          }
        }
        
        Button(role: .destructive, action: { showTransactionDeleteAlert.toggle() }) {
          Label("Delete transaction", image: "buttonDelete")
        }
      } label: {
        Source.Images.Navigation.menu
          .foregroundColor(.primaryGreen)
          .padding(20)
          .background(Color.secondaryYellow)
          .cornerRadius(40)
      }
      .font(.system(.subheadline, weight: .regular))
      .menuOrder(.fixed)
    }
  }
}
// MARK: - Realm Functions
extension TransactionDetailView {
  func deleteTransaction() {
    showTransactionDeleteAlert.toggle()
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      if transaction.categoryName == "Added funds" {
        try? realm.write {
          newBudget.amount -= transaction.amount
        }
      } else {
        try? realm.write {
          newBudget.amount += transaction.amount
        }
      }
    }
    
    if let transaction = transaction.thaw(), let realm = transaction.realm {
      try? realm.write {
        realm.delete(transaction)
      }
    }
    router.nav?.popViewController(animated: true)
  }
}
