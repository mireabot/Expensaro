//
//  RecurrentPaymentsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftUIIntrospect

struct RecurrentPaymentsListView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State var currentDate: Date = Date()
  
  @State private var showAddPayment = false
  @State private var showPaymentDetail = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXDatePicker(currentDate: $currentDate)
          .padding(.top, 20)
        
        VStack {
          if let payments = sampleRecurrentPayments.first(where: { payment in
            return isSameDay(date1: payment.paymentDueDate, date2: currentDate)
          }){
            LazyVStack(spacing: 15) {
              ForEach(payments.payments) { paymentData in
                Button {
                  router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentDetailView(payment: paymentData)))
                } label: {
                  EXRecurrentCell(paymentData: paymentData)
                }
                .buttonStyle(EXPlainButtonStyle())
              }
            }
          }
          else {
            emptyState()
          }
        }
        .applyMargins()
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showAddPayment, content: {
        AddRecurrentPaymentView()
          .presentationDetents([.large])
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
            .font(.mukta(.medium, size: 17))
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
      .introspect(.scrollView, on: .iOS(.v16,.v17)) { scrollView in
        scrollView.bounces = false
      }
    }
  }
}

struct RecurrentPaymentsListView_Previews: PreviewProvider {
  static var previews: some View {
    RecurrentPaymentsListView()
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
  func isSameDay(date1: Date,date2: Date)->Bool{
    let calendar = Calendar.current
    
    return calendar.isDate(date1, inSameDayAs: date2)
  }
}

// MARK: - Helper Views
extension RecurrentPaymentsListView {
  @ViewBuilder
  func emptyState() -> some View {
    VStack(alignment: .center, spacing: 3) {
      Text("You have no recurring payments for this date")
        .font(.mukta(.semibold, size: 15))
        .multilineTextAlignment(.center)
      Text("You can create one with plus button on the top")
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 20)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}
