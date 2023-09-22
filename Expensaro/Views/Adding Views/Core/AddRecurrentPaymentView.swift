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
  @FocusState private var isFieldFocused: Bool
  @State private var amountValue: String = ""
  @State private var paymentName: String = ""
  @State private var paymentDate: String = Source.Functions.showString(from: .now)
  @State private var paymentCategory: String = "Travel"
  @State private var paymentTag: String = ""
  
  @State private var showDateSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $paymentTag, type: .transactionType).padding(.top, 16)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(text: $amountValue, bottomView: EmptyView()).focused($isFieldFocused)
          EXTextField(text: $paymentName, placeholder: Appearance.shared.textFieldPlaceholder).focused($isFieldFocused)
          HStack {
            EXSmallSelector(activeText: $paymentDate, type: .date).onTapGesture {
              showDateSelector.toggle()
            }
            EXSmallSelector(activeText: $paymentCategory, type: .category)
          }
        }
      }
      .applyMargins()
      .onTapGesture {
        isFieldFocused = false
      }
      .sheet(isPresented: $showDateSelector, content: {
        DateSelectorView(title: Appearance.shared.dateSelectorTitle, selectedDate: $paymentDate)
          .presentationDetents([.medium])
      })
      .safeAreaInset(edge: .bottom, content: {
        Button {
          print(paymentTag)
        } label: {
          Text(Appearance.shared.buttonText)
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 15)
        .buttonStyle(PrimaryButtonStyle())
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .font(.callout)
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

// MARK: - Apperance
extension AddRecurrentPaymentView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add recurrent payment"
    let buttonText = "Add payment"
    let textFieldPlaceholder = "Ex. House Rent"
    let dateSelectorTitle = "Select pay date"
    
    let closeIcon = Source.Images.Navigation.close
  }
}
