//
//  RecurrentPaymentsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct RecurrentPaymentsListView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State var currentDate: Date = Date()
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Presentation
  @State private var showAddPayment = false
  @State private var showPaymentDetail = false
  
  // MARK: Realm
  @ObservedResults(RecurringTransaction.self) var recurringTransactions
  @ObservedRealmObject var budget: Budget
  var body: some View {
    NavigationView {
      ScrollView {
        EXDatePicker(currentDate: $currentDate, recurringTransactions: recurringTransactions)
          .padding(.top, 16)
        
        VStack {
          if let payments = groupedRecurringPayments.first(where: { payment in
            return isSameDay(date1: payment.paymentDueDate, date2: currentDate)
          }){
            VStack {
              Text("Upcoming payments on \(Text("\(displayDate(date: currentDate))").foregroundColor(.primaryGreen).font(.system(.title3, weight: .bold)))")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
              LazyVStack {
                ForEach(payments.payments) { paymentData in
                  Button {
                    router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentDetailView(transaction: paymentData, budget: budget)))
                  } label: {
                    EXRecurringTransactionCell(payment: paymentData)
                  }
                  .buttonStyle(EXPlainButtonStyle())
                }
              }
            }
          }
          else {
            EXEmptyStateView(type: .noRecurringPayments)
          }
        }
        .applyMargins()
        .padding(.bottom, 10)
      }
      .scrollBounceBehavior(.basedOnSize)
      .navigationBarTitleDisplayMode(.inline)
      .fullScreenCover(isPresented: $showAddPayment, content: {
        AddRecurrentPaymentView(recurringPayment: RecurringTransaction(), budget: budget)
      })
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .foregroundColor(.black)
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showAddPayment.toggle()
          } label: {
            Appearance.shared.addIcon
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

struct RecurrentPaymentsListView_Previews: PreviewProvider {
  static var previews: some View {
    RecurrentPaymentsListView(budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Appearance
extension RecurrentPaymentsListView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Recurring payments"
    
    let backIcon = Source.Images.Navigation.back
    let addIcon = Source.Images.ButtonIcons.add
  }
}

// MARK: - Helper Functions
extension RecurrentPaymentsListView {
  // Check are there any recurring payment for selected date
  func isSameDay(date1: Date, date2: Date) -> Bool{
    let calendar = Calendar.current
    return calendar.isDate(date1, inSameDayAs: date2)
  }
  
  // Displaying selected date's components (month and date)
  func displayDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: date)
  }
  
  // Grid layout for recurring payment cells
  static var items: [GridItem] = [
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10),
  ]
  
  var totalRecurringPayments: Double {
    var total: Double = 0
    for i in recurringTransactions {
      total += i.amount
    }
    return total
  }
  
  var groupedRecurringPayments: [RecurrentPaymentData] {
    var groupedTransactions: [Date: [RecurringTransaction]] {
      Dictionary(grouping: recurringTransactions) { transaction in
        let calendar = Calendar.current
        return calendar.startOfDay(for: transaction.dueDate)
      }
    }
    let recurrentPaymentDataArray = groupedTransactions.map { date, payments in
      RecurrentPaymentData(payments: payments, paymentDueDate: date)
    }
    return recurrentPaymentDataArray
  }
}

// MARK: - Helper Views
extension RecurrentPaymentsListView {
  @ViewBuilder
  func headerView() -> some View {
    EXBaseCard {
      VStack(alignment: .center, spacing: 3) {
        Text("\(totalRecurringPayments.formattedAsCurrency(with: currencySign))")
          .font(.title3Semibold)
        Text("Total spent on recurring payments")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
      .padding(4)
      .frame(maxWidth: .infinity)
    }
  }
}
