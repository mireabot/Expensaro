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
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: - Realm
  @ObservedRealmObject var transaction: RecurringTransaction
  @ObservedRealmObject var budget: Budget
  
  // MARK: - Variables
  @State private var errorType = EXToasts.none
  
  // MARK: - Presentation
  @State private var showDeleteAlert = false
  @State private var showEditPayment = false
  @State private var showNoteView = false
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing, content: {
        ScrollView {
          // MARK: Transaction header
          VStack(alignment: .leading, spacing: 3) {
            Text(transaction.name)
              .font(.title3Medium)
            
            Text("\(transaction.amount.formattedAsCurrency(with: currencySign))")
              .font(.largeTitleBold)
            
            Text("Next payment date: \(transaction.isDue ? daysLeftString(for: transaction.daysLeftUntilDueDate) : Source.Functions.showString(from: transaction.dueDate))")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, 16)
          
          if transaction.isDue {
            Button {
              withAnimation(.easeOut) {
                validateRenewal()
              }
            } label: {
              Text("Renew now")
                .font(.system(.subheadline, weight: .semibold))
            }
            .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
          }
          
          // MARK: Transaction info
          HStack(spacing: 5) {
            EXChip(icon: .imageName(transaction.categoryIcon), text: transaction.categoryName)
            EXChip(icon: .imageName(""), text: transaction.schedule.title)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, 5)
          
          // MARK: Transaction detail
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
          .padding(.top, 5)
          
          // MARK: Transaction reminders
          EXToggleCard(type: .paymentReminder, isOn: Binding(
            get: { transaction.isReminder },
            set: { newValue in
              AnalyticsManager.shared.log(.modifiedReminder(transaction.name))
              updateNotification(with: newValue)
            }
          ))
          .padding(.top, 5)
        }
        .applyBounce()
        bottomActionButton().padding(.bottom, 16)
        
      })
      .popup(isPresented: $showDeleteAlert) {
        EXAlert(type: .deletePayment, primaryAction: { deletePayment() }, secondaryAction: {showDeleteAlert.toggle()}).applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .position(.bottom)
          .type(.floater(useSafeAreaInset: true))
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .popup(isPresented: $showError, view: {
        EXToast(type: $errorType)
      }, customize: {
        $0
          .isOpaque(true)
          .type(.floater())
          .position(.top)
          .autohideIn(1.5)
      })
      .fullScreenCover(isPresented: $showEditPayment, content: {
        AddRecurrentPaymentView(recurringPayment: transaction, budget: budget)
      })
      .sheet(isPresented: $showNoteView, content: {
        noteView()
          .presentationDetents([.fraction(0.95)])
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
    RecurrentPaymentDetailView(transaction: Source.DefaultData.sampleRecurringPayments[0], budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Appearance
extension RecurrentPaymentDetailView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Transactions"
    
    let closeIcon = Source.Images.Navigation.back
    let dismissIcon = Source.Images.Navigation.close
    let deleteIcon = Source.Images.ButtonIcons.delete
  }
}

// MARK: - Helper Views
extension RecurrentPaymentDetailView {
  @ViewBuilder
  func noteView() -> some View {
    ScrollView {
      HStack {
        Text("Create note")
          .font(.title3Semibold)
        Spacer()
        Button(action: {
          showNoteView.toggle()
        }, label: {
          Appearance.shared.dismissIcon
            .foregroundColor(.black)
        })
      }
      .padding(.top, 20)
      EXResizableTextField(message: $transaction.note, characterLimit: 300)
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
      .font(.system(.subheadline, weight: .regular))
      .menuOrder(.fixed)
    }
  }
  
}
// MARK: - Realm Functions
extension RecurrentPaymentDetailView {
  func deletePayment() {
    AnalyticsManager.shared.log(.deletePayment)
    showDeleteAlert.toggle()
    
    if let newTransaction = transaction.thaw(), let realm = newTransaction.realm {
      if let newBudget = budget.thaw(), let realm = newBudget.realm {
        if !newTransaction.isDue {
          try? realm.write {
            newBudget.amount += newTransaction.amount
          }
        }
      }
      notificationManager.deleteNotification(for: newTransaction)
      try? realm.write {
        realm.delete(newTransaction.contributions)
        realm.delete(newTransaction)
      }
    }
    router.nav?.popViewController(animated: true)
  }
  
  func addContribution() {
    if let payment = transaction.thaw(), let realm = payment.realm {
      AnalyticsManager.shared.log(.paymentRenewed(payment.name, payment.amount))
      let contribution = Source.Realm.createPaymentContribution(amount: payment.amount, date: Date())
      try? realm.write {
        payment.contributions.append(contribution)
      }
    }
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
  
  func validateRenewal() {
    if transaction.amount > budget.amount {
      errorType = .budgetExceed
      showError.toggle()
    } else {
      renewPayment()
      addContribution()
    }
  }
}
