//
//  TransactionInsightsDemoView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/15/23.
//

import SwiftUI
import ExpensaroUIKit

struct TransactionInsightsDemoView: View {
  var body: some View {
    EXBaseCard {
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Text("$109.68")
              .font(.title3Bold)
              .foregroundColor(.black)
            Text("Avg. transaction amount")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          }
          
          Spacer()
          
          Source.Images.InfoCardIcon.month2month
            .foregroundColor(.primaryGreen)
        }
        VStack(alignment: .leading, spacing: 5) {
          Text("Top 3 transactions in category")
            .font(.footnoteMedium)
            .foregroundColor(.black)
          VStack(spacing: 10) {
            HStack(alignment: .center) {
              Text("Nike shoes")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
                
              Spacer()
              
              Text("$118.50")
                .font(.footnoteMedium)
                .foregroundColor(.primaryGreen)
            }
            HStack(alignment: .center) {
              Text("Electronics purchase")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
                
              Spacer()
              
              Text("$68.09")
                .font(.footnoteMedium)
                .foregroundColor(.primaryGreen)
            }
            HStack(alignment: .center) {
              Text("Books")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
                
              Spacer()
              
              Text("$54.49")
                .font(.footnoteMedium)
                .foregroundColor(.primaryGreen)
            }
          }
          .padding(.top, 3)
        }
        .padding(10)
        .background(.white)
        .cornerRadius(8)
        .padding(.top, 5)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  TransactionInsightsDemoView()
}
