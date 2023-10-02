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
  var body: some View {
    NavigationView {
      ScrollView {
        EXDatePicker(currentDate: $currentDate)
          .padding(.top, 20)
        
        VStack {
          if let _ = RecurrentPayment.recurrentPayments.first(where: { payment in
            return isSameDay(date1: payment.dueDate, date2: currentDate)
          }){
            LazyVStack(spacing: 15) {
              ForEach(RecurrentPayment.recurrentPayments) { paymentData in
                EXRecurrentCell(paymentData: paymentData)
              }
            }
          }
          else {
            Text("No Payments Found")
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
    
    let title = "Recurrent payments"
    
    let backIcon = Source.Images.Navigation.back
    let addIcon = Source.Images.ButtonIcons.add
  }
}

extension RecurrentPaymentsListView {
  func isSameDay(date1: Date,date2: Date)->Bool{
    let calendar = Calendar.current
    
    return calendar.isDate(date1, inSameDayAs: date2)
  }
}
