//
//  AddTransactionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit

struct AddTransactionView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var amountFieldFocused: Bool
  @FocusState private var nameFieldFocused: Bool
  @State private var amountValue: String = ""
  @State private var transactionName: String = ""
  @State private var transactionCategory: String = "Travel"
  @State private var transactionImage: Image = Source.Images.System.analytics
  @State private var transactionTag: String = ""
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $transactionTag, type: .transactionType).padding(.top, 20)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(text: $amountValue, bottomView: EmptyView()).focused($amountFieldFocused)
          EXTextField(text: $transactionName, placeholder: Appearance.shared.textFieldPlaceholder)
          EXLargeSelector(text: transactionCategory, icon: transactionImage, buttonText: "Change", action: {})
          Text(Appearance.shared.infoText)
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .onTapGesture {
        amountFieldFocused = false
      }
      .applyMargins()
      .safeAreaInset(edge: .bottom, content: {
        Button {
          print(transactionTag)
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
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(.black)
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.cameraIcon
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(.primaryGreen)
          }
        }
      }
    }
  }
}

struct AddTransactionView_Previews: PreviewProvider {
  static var previews: some View {
    AddTransactionView()
  }
}

// MARK: - Apperance
extension AddTransactionView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add Transaction"
    let buttonText = "Add transaction"
    let textFieldPlaceholder = "Ex. House Rent"
    let infoText = "For your convenience date of transaction will be today. You can change it anytime in transaction card"
    
    let closeIcon = Source.Images.Navigation.close
    let cameraIcon = Source.Images.System.scan
  }
}
