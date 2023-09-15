//
//  AddRecurrentPaymentView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit

struct AddRecurrentPaymentView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var amountFieldFocused: Bool
  @FocusState private var nameFieldFocused: Bool
  @State private var amountValue: String = ""
  @State private var paymentName: String = ""
  @State private var paymentDate: String = "Oct 2024"
  @State private var paymentCategory: String = "Travel"
  @State private var paymentTag: String = ""
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $paymentTag, type: .transactionType).padding(.top, 20)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(text: $amountValue, bottomView: EmptyView())
          EXTextField(text: $paymentName, placeholder: "Ex. House Rent")
          HStack {
            EXSmallSelector(activeText: paymentDate, icon: .init(systemName: "globe"), type: .date)
            EXSmallSelector(activeText: paymentCategory, icon: .init(systemName: "globe"), type: .category)
          }
        }
      }
      .applyMargins()
      .safeAreaInset(edge: .bottom, content: {
        Button {
          print(paymentTag)
        } label: {
          Text("Add recurrent payment")
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 20)
        .buttonStyle(PrimaryButtonStyle())
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Add recurrent payment")
            .font(.mukta(.medium, size: 17))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Source.Images.Navigation.close
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

struct AddRecurrentPaymentView_Previews: PreviewProvider {
  static var previews: some View {
    AddRecurrentPaymentView()
  }
}
