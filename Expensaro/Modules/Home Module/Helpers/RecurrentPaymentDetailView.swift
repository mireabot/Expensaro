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
  // MARK: - Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  let notificationManager: NotificationManager = NotificationManager.shared
  
  // MARK: - Realm
  @ObservedRealmObject var transaction: RecurringTransaction
  @ObservedRealmObject var budget: Budget
  
  
  // MARK: - Presentation
  @State private var showDeleteAlert = false
  @State private var showEditPayment = false
  @State private var showNoteView = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing, content: {
        ScrollView {
          // MARK: Transaction header
          HStack {
            VStack(alignment: .leading, spacing: 3) {
              Text(transaction.name)
                .font(.mukta(.medium, size: 20))
              
              Text("$\(transaction.amount.withDecimals)")
                .font(.mukta(.bold, size: 34))
              
              Text("Next payment date: \(transaction.isDue ? daysLeftString(for: transaction.daysLeftUntilDueDate) : Source.Functions.showString(from: transaction.dueDate))")
                .font(.mukta(.regular, size: 15))
                .foregroundColor(.darkGrey)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          
          if transaction.isDue {
            Button {
              withAnimation(.easeOut) {
                renewPayment()
              }
            } label: {
              Text("Renew now")
                .font(.mukta(.medium, size: 15))
            }
            .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
          }
          
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
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(Color.border, lineWidth: 1)
            )
            
            if !transaction.note.isEmpty {
              Button {
                showNoteView.toggle()
              } label: {
                HStack {
                  Source.Images.ButtonIcons.note
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
            }
            
            EXToggleCard(type: .paymentReminder, isOn: Binding(
              get: { transaction.isReminder },
              set: { newValue in
                  updateNotification(with: newValue)
              }
          ))
          }
          .padding(.top, 10)
          
        }
        bottomActionButton().padding(.bottom, 16)
        
      })
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
  
  func daysLeftString(for days: Int) -> String {
    switch days {
    case -1:
      return "Overdue 1 day"
    case 0:
      return "Today"
    default:
      return "Overdue \(abs(days)) days"
    }
  }
}

struct RecurrentPaymentDetailView_Previews: PreviewProvider {
  static var previews: some View {
    RecurrentPaymentDetailView(transaction: DefaultRecurringTransactions.transaction2, budget: Budget())
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
        
        if transaction.note.isEmpty {
          Button(action: { showNoteView.toggle() }) {
            Label("Create note", image: "buttonNote")
          }
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
    
    if let newTransaction = transaction.thaw(), let realm = newTransaction.realm {
      if let newBudget = budget.thaw(), let realm = newBudget.realm {
        try? realm.write {
          newBudget.amount += newTransaction.amount
        }
      }
      notificationManager.deleteNotification(for: newTransaction)
      try? realm.write {
        realm.delete(newTransaction)
      }
    }
    router.nav?.popViewController(animated: true)
  }
  
  func updateNotification(with value: Bool) {
    if let newTransaction = transaction.thaw(), let newRealm = newTransaction.realm {
      if value {
        notificationManager.scheduleTriggerNotification(for: newTransaction)
      }
      else {
        notificationManager.deleteNotification(for: newTransaction)
      }
      try? newRealm.write {
        newTransaction.isReminder = value
      }
    }
  }
  
  func renewPayment() {
    var newDate = Date()
    switch transaction.schedule {
    case .everyWeek:
      print("Now date: \(Source.Functions.showString(from: transaction.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 7, date: transaction.dueDate)))")
      newDate = getSampleDate(offset: 7, date: transaction.dueDate)
    case .everyMonth:
      print("Now date: \(Source.Functions.showString(from: transaction.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 31, date: transaction.dueDate)))")
      newDate = getSampleDate(offset: 31, date: transaction.dueDate)
    case .every3Month:
      print("Now date: \(Source.Functions.showString(from: transaction.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 90, date: transaction.dueDate)))")
      newDate = getSampleDate(offset: 90, date: transaction.dueDate)
    case .everyYear:
      print("Now date: \(Source.Functions.showString(from: transaction.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 365, date: transaction.dueDate)))")
      newDate = getSampleDate(offset: 365, date: transaction.dueDate)
    }
    // Set new due date
    if let newPayment = transaction.thaw(), let paymentRealm = newPayment.realm {
      try? paymentRealm.write {
        newPayment.dueDate = newDate
      }
      if newPayment.isReminder {
        notificationManager.scheduleTriggerNotification(for: newPayment)
      }
      // Update budget
      if let newBudget = budget.thaw(), let budgetRealm = newBudget.realm {
        try? budgetRealm.write {
          newBudget.amount -= newPayment.amount
        }
      }
    }
  }
}
