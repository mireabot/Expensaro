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
  @State private var showCategoryelector = false
  @State private var showReminderAlert = false
  
  @State private var showAnimation = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $paymentTag, type: .transactionType).padding(.top, 16)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(text: $amountValue, bottomView: EmptyView()).focused($isFieldFocused)
          EXTextField(text: $paymentName, placeholder: Appearance.shared.textFieldPlaceholder)
            .keyboardType(.alphabet)
            .focused($isFieldFocused)
          HStack {
            EXSmallSelector(activeText: $paymentDate, type: .date).onTapGesture {
              showDateSelector.toggle()
            }
            EXSmallSelector(activeText: $paymentCategory, type: .category).onTapGesture {
              showCategoryelector.toggle()
            }
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
      .sheet(isPresented: $showReminderAlert, content: {
        reminderBottomView()
          .presentationDetents([.fraction(0.3)])
      })
      .sheet(isPresented: $showCategoryelector, content: {
        CategorySelectorView(title: $paymentCategory, icon: .constant(.init(systemName: "globe")))
          .presentationDetents([.medium, .fraction(0.9)])
          .presentationDragIndicator(.visible)
      })
      .safeAreaInset(edge: .bottom, content: {
        Button {
          showReminderAlert.toggle()
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
private extension AddRecurrentPaymentView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add recurrent payment"
    let buttonText = "Add payment"
    let textFieldPlaceholder = "Ex. House Rent"
    let dateSelectorTitle = "Select pay date"
    
    let closeIcon = Source.Images.Navigation.close
    
    let reminderTitle = "Do you want to create reminder?"
    let reminderText = "You will receive a notification 3 days in advance of your upcoming payment"
    let successTitle = "You are all set!"
    let successText = "You will get a reminder 3 days before the date of payment"
  }
}


// MARK: - Helper Views
extension AddRecurrentPaymentView {
  @ViewBuilder
  func reminderBottomView() -> some View {
    VStack(spacing: 10) {
      Text(showAnimation ? Appearance.shared.successTitle : Appearance.shared.reminderTitle)
        .font(.mukta(.semibold, size: 20))
      Text(showAnimation ? Appearance.shared.successText : Appearance.shared.reminderText)
        .multilineTextAlignment(.center)
        .font(.mukta(.regular, size: 17))
        .foregroundColor(.darkGrey)
        .padding(.bottom, 25)
    }
    .safeAreaInset(edge: .bottom, content: {
      ZStack {
        if showAnimation {
          Button {
            showReminderAlert.toggle()
          } label: {
            Text("Done")
              .font(.mukta(.semibold, size: 17))
          }
          .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
          .zIndex(1)
          .transition(.move(edge: .trailing))
        }
        
        HStack {
          Button {
            
            showReminderAlert.toggle()
          } label: {
            Text("No, thank you")
              .font(.mukta(.semibold, size: 17))
          }
          .buttonStyle(SmallPrimaryButtonStyle(showLoader: .constant(false)))
          Button {
            withAnimation(.interactiveSpring(response: 0.5,dampingFraction: 0.9, blendDuration: 0.9)) {
              showAnimation.toggle()
            }
          } label: {
            Text("Yes, I'm in")
              .font(.mukta(.semibold, size: 17))
          }
          .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
        }
        .background(.white)
        .zIndex(showAnimation ? 0 : 1)

      }
    })
    .applyMargins()
    .interactiveDismissDisabled()
  }
}
