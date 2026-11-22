//
//  RecurrentPaymentDetailView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/7/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import PopupView
import SwiftData

struct RecurrentPaymentDetailView: View {
  // MARK: - Essential
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: - Storage
  @Bindable var transaction: RecurringTransaction
  @Bindable var budget: Budget
  
  // MARK: - Variables
  @State private var errorType = EXToasts.none
  
  // MARK: - Presentation
  @State private var showNoteView = false
  @State private var showError = false
  var body: some View {
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
      EXToggleCard(config: (Source.Strings.ToggleType.paymentReminder.title,
                            Source.Strings.ToggleType.paymentReminder.text),
                   isOn: Binding(
                    get: { transaction.isReminder },
                    set: { newValue in
                      updateNotification(with: newValue)
                    }
                   ))
      .padding(.top, 5)
    }
    .scrollBounceBehavior(.basedOnSize)
    .popup(isPresented: $showError, view: {
      EXToast(type: $errorType)
    }, customize: {
      $0
        .isOpaque(true)
        .type(.floater())
        .position(.top)
        .autohideIn(1.5)
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
          router.back()
        } label: {
          Appearance.shared.closeIcon
            .foregroundColor(.black)
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
      .modelContainer(AppModelStore.preview)
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
}
// MARK: - Storage Functions
extension RecurrentPaymentDetailView {
  func updateNotification(with value: Bool) {
    try? transaction.setReminder(value)
  }
  
  func validateRenewal() {
    if transaction.amount > budget.amount {
      errorType = .budgetExceed
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    } else {
      try? transaction.renew(from: budget)
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
  }
}
