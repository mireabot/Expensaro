//
//  RecurrentPaymentDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/7/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView
import RealmSwift

struct RecurrentPaymentDetailView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  @ObservedRealmObject var transaction: RecurringTransaction
  @ObservedRealmObject var budget: Budget
  
  @State private var isOn = false
  @State private var showDeleteAlert = false
  @State private var showEditPayment = false
  @State private var showNoteView = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing, content: {
        ScrollView {
          // MARK: Transaction header
          VStack(alignment: .leading, spacing: 3) {
            Text(transaction.name)
              .font(.mukta(.medium, size: 20))
            
            Text("$\(transaction.amount.clean)")
              .font(.mukta(.bold, size: 34))
            
            Text("Next payment date: \(Source.Functions.showString(from: transaction.dueDate))")
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
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              
              HStack {
                Source.Images.System.calendarYear
                  .foregroundColor(.black)
                  .padding(8)
                VStack(alignment: .leading, spacing: -3) {
                  Text("Schedule")
                    .font(.mukta(.regular, size: 15))
                    .foregroundColor(.darkGrey)
                  Text(transaction.schedule.title)
                    .font(.mukta(.medium, size: 15))
                    .foregroundColor(.black)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
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
              .padding(10)
              .background(.white)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .inset(by: 0.5)
                  .stroke(Color.border, lineWidth: 1)
              )
            }
            .buttonStyle(EXPlainButtonStyle())
            
            EXToggleCard(type: .paymentReminder, isOn: $isOn)
          }
          .padding(.top, 10)
          
        }
        bottomActionButton().padding(.bottom, 16)
      })
      .onAppear {
        isOn = transaction.isReminder
      }
      .popup(isPresented: $showDeleteAlert) {
        EXAlert(type: .deleteTransaction, primaryAction: { deletePayment() }, secondaryAction: {showDeleteAlert.toggle()}).applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .fullScreenCover(isPresented: $showEditPayment, content: {
        AddRecurrentPaymentView(recurringPayment: transaction, budget: budget)
      })
      .sheet(isPresented: $showNoteView, content: {
        noteView()
          .presentationDetents([.large])
      })
      .applyMargins()
      .scrollDisabled(true)
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

struct RecurrentPaymentDetailView_Previews: PreviewProvider {
  static var previews: some View {
    RecurrentPaymentDetailView(transaction: DefaultRecurringTransactions.transaction1, budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Appearance
extension RecurrentPaymentDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let closeIcon = Source.Images.Navigation.back
    let deleteIcon = Source.Images.ButtonIcons.delete
  }
}

// MARK: - Helper Views
extension RecurrentPaymentDetailView {
  @ViewBuilder
  func noteView() -> some View {
    NavigationView {
      ScrollView {
        EXResizableTextField(message: $transaction.note, characterLimit: 300)
          .autocorrectionDisabled()
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
        .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
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
  
  @ViewBuilder
  func bottomActionButton() -> some View {
    VStack {
      Menu {
        Button(action: { showEditPayment.toggle() }) {
          Label("Edit payment", image: "buttonEdit")
        }
        
        Button(role: .destructive, action: { showDeleteAlert.toggle() }) {
          Label("Delete payment", image: "buttonDelete")
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
// MARK: - Realm Functions
extension RecurrentPaymentDetailView {
  func deletePayment() {
    showDeleteAlert.toggle()
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += transaction.amount
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
