//
//  RecurrentPaymentCell.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXRecurrentCell: View {
  let paymentData: RecurrentPayment
  
  init(paymentData: RecurrentPayment) {
    self.paymentData = paymentData
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(paymentData.name)
        .font(.mukta(.medium, size: 15))
        .multilineTextAlignment(.leading)
      HStack(alignment: .center, spacing: 1) {
        Text("$\(paymentData.amount.clean)")
          .font(.mukta(.medium, size: 13))
          .lineLimit(3)
        Text("/ \(Int(paymentData.maxValue - paymentData.currentValue)) days left")
          .foregroundColor(.darkGrey)
          .font(.mukta(.regular, size: 11))
          .lineLimit(3)
      }
      ProgressView(value: paymentData.currentValue, total: paymentData.maxValue, label: {})
        .tint(.primaryGreen)
    }
    .padding(10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct RecurrentPaymentCell_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      EXRecurrentCell(paymentData: RecurrentPayment.recurrentPayments[0])
      EXRecurrentCell(paymentData: RecurrentPayment.recurrentPayments[1])
      EXRecurrentCell(paymentData: RecurrentPayment.recurrentPayments[2])
    }
    .padding([.leading,.trailing], 16)
  }
}
