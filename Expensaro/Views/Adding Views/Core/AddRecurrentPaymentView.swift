//
//  AddRecurrentPaymentView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct AddRecurrentPaymentView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  
  @Environment(\.realm) var realm
  @ObservedRealmObject var recurringPayment: RecurringTransaction
  @ObservedRealmObject var budget: Budget
  
  @State private var showDateSelector = false
  @State private var showCategoryelector = false
  @State private var showReminderAlert = false
  
  @State private var paymentPeriodicity = "Not selected"
  
  @State private var showAnimation = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXSegmentControl(currentTab: $recurringPayment.type, type: .transactionType).padding(.top, 16)
        VStack(spacing: 20) {
          EXLargeCurrencyTextField(value: $recurringPayment.amount, bottomView: EmptyView()).focused($isFieldFocused)
          EXTextField(text: $recurringPayment.name, placeholder: Appearance.shared.textFieldPlaceholder)
            .keyboardType(.alphabet)
            .focused($isFieldFocused)
          VStack(alignment: .leading, spacing: 5) {
            Text("Select payment category")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
            EXLargeSelector(text: $recurringPayment.categoryName, icon: $recurringPayment.categoryIcon, buttonText: "Change", action: {
              showCategoryelector.toggle()
            })
          }
          VStack(alignment: .leading, spacing: 5) {
            Text("Select payment periodicity")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
            dateSelector(date: $recurringPayment.dueDate, title: $paymentPeriodicity) {
              showDateSelector.toggle()
            }
          }
        }
      }
      .applyMargins()
      .onTapGesture {
        isFieldFocused = false
      }
      .sheet(isPresented: $showDateSelector, content: {
        PeriodicitySelectorView(selectedPeriodicity: $paymentPeriodicity, newDate: $recurringPayment.dueDate)
          .presentationDetents([.fraction(0.4)])
      })
      .sheet(isPresented: $showReminderAlert, content: {
        reminderBottomView()
          .presentationDetents([.fraction(0.3)])
      })
      .sheet(isPresented: $showCategoryelector, content: {
        CategorySelectorView(title: $recurringPayment.categoryName, icon: $recurringPayment.categoryIcon)
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
        .disabled(recurringPayment.name.isEmpty || recurringPayment.amount == 0)
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
    AddRecurrentPaymentView(recurringPayment: RecurringTransaction(), budget: Budget())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Apperance
private extension AddRecurrentPaymentView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add recurring payment"
    let buttonText = "Add payment"
    let textFieldPlaceholder = "Ex. House Rent"
    
    let closeIcon = Source.Images.Navigation.close
    let timerIcon = Source.Images.System.calendarYear
    
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
            makeDismiss()
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
            createPayment()
            showReminderAlert.toggle()
            makeDismiss()
          } label: {
            Text("No, thank you")
              .font(.mukta(.semibold, size: 17))
          }
          .buttonStyle(SmallPrimaryButtonStyle(showLoader: .constant(false)))
          Button {
            recurringPayment.isReminder.toggle()
            createPayment()
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
  
  @ViewBuilder
  func dateSelector(date: Binding<Date>, title: Binding<String>, action: @escaping() -> Void) -> some View {
    HStack {
      HStack(spacing: 10) {
        Image("timer")
          .foregroundColor(.primaryGreen)
          .padding(10)
          .background(Color.backgroundGrey)
          .cornerRadius(12)
        VStack(alignment: .leading, spacing: 0) {
          Text(title.wrappedValue)
            .font(.mukta(.regular, size: 17))
          Text("\(Source.Functions.showString(from: date.wrappedValue))")
            .font(.mukta(.regular, size: 13))
            .foregroundColor(.darkGrey)
        }
      }
      Spacer()
      
      
      Button(action: action) {
        Text("Change")
          .font(.mukta(.medium, size: 15))
      }
      .buttonStyle(SmallButtonStyle())
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.5)
        .stroke(Color.border, lineWidth: 1)
    )
  }
}

// MARK: - Realm Functions
extension AddRecurrentPaymentView {
  func createPayment() {
    try? realm.write {
      realm.add(recurringPayment)
    }
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount -= recurringPayment.amount
      }
    }
  }
}
