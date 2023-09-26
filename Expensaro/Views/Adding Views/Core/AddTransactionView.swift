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
  @FocusState private var isFieldFocused: Bool
  @State private var amountValue: String = ""
  @State private var transactionName: String = ""
  @State private var transactionCategory: String = "Other"
  @State private var transactionImage: Image = Source.Images.System.defaultCategory
  @State private var transactionTag: String = ""
  
  @State private var showCategoriesSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $transactionTag, type: .transactionType).padding(.top, 16)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(text: $amountValue, bottomView: EmptyView()).focused($isFieldFocused)
          EXTextField(text: $transactionName, placeholder: Appearance.shared.textFieldPlaceholder)
            .keyboardType(.alphabet)
            .focused($isFieldFocused)
          EXLargeSelector(text: $transactionCategory, icon: $transactionImage, buttonText: "Change", action: {
            showCategoriesSelector.toggle()
          })
          Text(Appearance.shared.infoText)
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .onTapGesture {
        isFieldFocused = false
      }
      .applyMargins()
      .sheet(isPresented: $showCategoriesSelector, content: {
        CategorySelectorView(title: $transactionCategory, icon: $transactionImage)
          .presentationDetents([.medium,.fraction(0.9)])
          .presentationDragIndicator(.visible)
      })
      .safeAreaInset(edge: .bottom, content: {
        Button {
          print(transactionTag)
        } label: {
          Text(Appearance.shared.buttonText)
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 15)
        .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
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
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.cameraIcon
              .font(.callout)
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

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // Update the view if needed
    }
}
