//
//  RecurringPaymentsRenewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/1/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct RecurringPaymentsRenewView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @State private var currentIndex: Int = 0
  
  // MARK: Realm
  @ObservedRealmObject var budget: Budget
  @ObservedResults(RecurringTransaction.self, filter: NSPredicate(format: "dueDate >= %@ AND dueDate < %@", Calendar.current.date(byAdding: .day, value: 0, to: Date())! as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: Date())! as NSDate)) var payments
  
  // MARK: Presentation
  @State private var showAnimation = false
  var body: some View {
    NavigationView(content: {
      ScrollView {
        VStack(alignment: .leading, spacing: 0, content: {
          Text("You have payments which are due tomorrow")
            .font(.mukta(.medium, size: 20))
          Text("Renew them or delete from list")
            .font(.mukta(.regular, size: 15))
            .foregroundStyle(Color.darkGrey)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        GeometryReader{_ in
          if showAnimation {
            successView()
          } else {
            ForEach(payments.indices,id: \.self) { index in
              if currentIndex == index {
                EXRecurringPaymentRenewCell(payment: payments[currentIndex])
                  .frame(maxWidth: .infinity)
                  .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
              }
            }
          }
        }
      }
      .applyMargins()
      .scrollDisabled(true)
      .interactiveDismissDisabled(true)
      .safeAreaInset(edge: .bottom, content: {
        ZStack {
          HStack {
            Button(action: {
              if currentIndex == (payments.count - 1) {
                renewPayment(for: payments[currentIndex]) {
                  withAnimation(.easeInOut){
                    showAnimation.toggle()
                  }
                }
              } else {
                renewPayment(for: payments[currentIndex]) {
                  withAnimation(.easeInOut){
                    currentIndex += 1
                  }
                }
              }
            }, label: {
              Text("Renew payment")
                .font(.mukta(.semibold, size: 17))
            })
            .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
            
            Button(action: {
              if currentIndex == (payments.count - 1) {
                deletePayment(for: payments[currentIndex]) {
                  withAnimation(.easeInOut){
                    showAnimation.toggle()
                  }
                }
              } else {
                deletePayment(for: payments[currentIndex]) {
                  withAnimation(.easeInOut) {
                    currentIndex += 1
                  }
                }
              }
            }, label: {
              Text("Delete payment")
                .font(.mukta(.semibold, size: 17))
            })
            .buttonStyle(SmallPrimaryButtonStyle(showLoader: .constant(false)))
          }
          
          if showAnimation {
            Button(action: {
              makeDismiss()
            }, label: {
              Text("Done")
                .font(.mukta(.semibold, size: 17))
            })
            .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
          }
        }
        .applyMargins()
        .padding(.bottom, 15)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .foregroundColor(.black)
          }
        }
      })
    })
  }
}

// MARK: - Apperance
extension RecurringPaymentsRenewView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Review upcoming payments"
    
    let closeIcon = Source.Images.Navigation.close
  }
}

// MARK: - Helper View
extension RecurringPaymentsRenewView {
  @ViewBuilder
  func successView() -> some View {
    VStack(alignment: .center, spacing: 5) {
      Source.Images.Navigation.checkmark
        .resizable()
        .frame(width: 30, height: 30)
        .foregroundColor(.primaryGreen)
      VStack(alignment: .center, spacing: -3, content: {
        Text("All set!")
          .font(.mukta(.semibold, size: 17))
        Text("You have reviewed all upcoming payments")
          .font(.mukta(.regular, size: 15))
          .foregroundStyle(Color.darkGrey)
      })
    }
    .padding(12)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .frame(maxWidth: .infinity)
  }
}


// MARK: - Realm Functions
extension RecurringPaymentsRenewView {
  func renewPayment(for payment: RecurringTransaction, completion: @escaping() -> Void) {
    var newDate = Date()
    switch payment.schedule {
    case .everyWeek:
      print("Now date: \(Source.Functions.showString(from: payment.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 7, date: payment.dueDate)))")
      newDate = getSampleDate(offset: 7, date: payment.dueDate)
    case .everyMonth:
      print("Now date: \(Source.Functions.showString(from: payment.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 31, date: payment.dueDate)))")
      newDate = getSampleDate(offset: 31, date: payment.dueDate)
    case .every3Month:
      print("Now date: \(Source.Functions.showString(from: payment.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 90, date: payment.dueDate)))")
      newDate = getSampleDate(offset: 90, date: payment.dueDate)
    case .everyYear:
      print("Now date: \(Source.Functions.showString(from: payment.dueDate)) -> Next date \(Source.Functions.showString(from: getSampleDate(offset: 365, date: payment.dueDate)))")
      newDate = getSampleDate(offset: 365, date: payment.dueDate)
    }
    // Set new due date
    if let newPayment = payment.thaw(), let paymentRealm = newPayment.realm {
      try? paymentRealm.write {
        newPayment.dueDate = newDate
      }
      // Update budget
      if let newBudget = budget.thaw(), let budgetRealm = newBudget.realm {
        try? budgetRealm.write {
          newBudget.amount += newPayment.amount
        }
      }
    }
    completion()
  }
  
  func deletePayment(for payment: RecurringTransaction, completion: @escaping() -> Void) {
    $payments.remove(payment)
    completion()
  }
}
