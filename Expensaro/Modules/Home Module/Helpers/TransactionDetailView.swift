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
  @State private var showChangeCategory = false
  @State private var showNoteView = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
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
        
        // MARK: Transaction detail
        VStack(spacing: 10) {
          Text("Information")
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity, alignment: .leading)
          VStack(spacing: 15) {
            Button {
              showChangeCategory.toggle()
            } label: {
              HStack {
                Image(transaction.categoryIcon)
                  .foregroundColor(.primaryGreen)
                  .padding(8)
                  .background(Color.backgroundGrey)
                  .cornerRadius(12)
                VStack(alignment: .leading, spacing: -3) {
                  Text("Category")
                    .font(.mukta(.regular, size: 15))
                    .foregroundColor(.darkGrey)
                  Text(transaction.categoryName)
                    .font(.mukta(.medium, size: 15))
                    .foregroundColor(.black)
                }
                if transaction.categoryName != "Added funds" {
                  Spacer()
                  Source.Images.ButtonIcons.selector
                    .resizable()
                    .frame(width: 20, height: 20)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(.white)
            }
            .buttonStyle(EXPlainButtonStyle())
            .disabled(transaction.categoryName == "Added funds")
            
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
          .padding(12)
          .background(.white)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .inset(by: 0.5)
              .stroke(Color.border, lineWidth: 1)
          )
          
          Button {
            showNoteView.toggle()
          } label: {
            HStack {
              Source.Images.ButtonIcons.edit
                .padding(8)
              VStack(alignment: .leading, spacing: -3) {
                Text("Note")
                  .font(.mukta(.regular, size: 15))
                  .foregroundColor(.darkGrey)
                Text(transaction.note)
                  .font(.mukta(.medium, size: 15))
                  .foregroundColor(.black)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.white)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(Color.border, lineWidth: 1)
            )
          }
          .buttonStyle(EXPlainButtonStyle())
        }
        .padding(.top, 10)
        
        // MARK: Analytics
        VStack(spacing: 10) {
          Text("Insights")
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity, alignment: .leading)
          TransactionInsightsView(viewModel: TransactionInsightsViewModel(category: transaction.categoryName, budget: budget.amount))
        }
        .padding([.top, .bottom], 10)
      }
      .applyMargins()
      .popup(isPresented: $showTransactionDeleteAlert) {
        EXAlert(type: .deleteTransaction, primaryAction: { deleteTransaction() }, secondaryAction: {showTransactionDeleteAlert.toggle()}).applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .sheet(isPresented: $showChangeCategory, content: {
        CategorySelectorView(title: $transaction.categoryName, icon: $transaction.categoryIcon)
          .presentationDetents([.fraction(0.9)])
      })
      .sheet(isPresented: $showNoteView, content: {
        noteView()
          .presentationDetents([.large])
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
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showTransactionDeleteAlert.toggle()
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
    TransactionDetailView(transaction: DefaultTransactions.transaction2, budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
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
  @ViewBuilder
  func noteView() -> some View {
    NavigationView {
      ScrollView {
        EXResizableTextField(message: $transaction.note, characterLimit: 300)
          .autocorrectionDisabled()
          .multilineSubmitEnabled(for: $transaction.note)
      }
      .applyMargins()
      .navigationBarTitleDisplayMode(.inline)
      .safeAreaInset(edge: .bottom) {
        Button {
          showNoteView.toggle()
        } label: {
          Text("Add note")
            .font(.mukta(.semibold, size: 17))
        }
        .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
        .applyMargins()
        .padding(.bottom, 20)
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Create note")
            .font(.mukta(.medium, size: 17))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showNoteView.toggle()
          } label: {
            Source.Images.Navigation.close
              .foregroundColor(.black)
          }
        }
      }
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
