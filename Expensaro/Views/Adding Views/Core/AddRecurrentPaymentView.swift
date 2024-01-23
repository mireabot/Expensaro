//
//  AddRecurrentPaymentView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct AddRecurrentPaymentView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  let notificationManager: NotificationManager = NotificationManager.shared
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var recurringPayment: RecurringTransaction
  @ObservedRealmObject var budget: Budget
  var isUpdating: Bool {
    recurringPayment.realm != nil
  }
  
  // MARK: Variables
  @State private var paymentPeriodicity = "Not selected"
  @State var amountValue: String = "0.0"
  @State private var budgetValue: Double = 0
  @State private var isBudgetAvailable = true
  @State private var isLoading = false
  @State private var savedDate = Date()
  
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Error
  @State private var errorType = EXToasts.none
  
  // MARK: Presentation
  @State private var showAnimation = false
  @State private var showSchedule = false
  @State private var showNextDate = false
  @State private var showCategoryelector = false
  @State private var showReminderAlert = false
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          EXSegmentControl(currentTab: $recurringPayment.type, type: .transactionType).padding(.top, 20)
          VStack(spacing: 20) {
            VStack(spacing: 10) {
              recurringTextField()
              budgetSection()
            }
            EXTextField(text: $recurringPayment.name, header: "Payment name", placeholder: Appearance.shared.textFieldPlaceholder)
              .autocorrectionDisabled()
              .focused($isFieldFocused)
            Button(action: {
              showCategoryelector.toggle()
            }) {
              EXLargeSelector(text: $recurringPayment.categoryName, icon: .constant(.imageName(recurringPayment.categoryIcon)), header: "Category", rightIcon: "swipeDown")
            }
            .buttonStyle(EXPlainButtonStyle())
          }
          .padding(.top, 20)
        }
        .applyBounce()
        
        VStack {
          HStack {
            Button(action: {
              showSchedule.toggle()
            }) {
              EXSmallSelector(activeText: .constant(recurringPayment.schedule.title), icon: "buttonRecurrent")
            }
            .buttonStyle(EXPlainButtonStyle())
            
            Button(action: {
              showNextDate.toggle()
            }) {
              EXSmallSelector(activeText: .constant(Source.Functions.showString(from: recurringPayment.dueDate)), icon: "calendarYear")
            }
            .buttonStyle(EXPlainButtonStyle())
          }
          EXNumberKeyboard(textValue: $amountValue) {
            if Double(amountValue) == recurringPayment.amount && isUpdating {
              makeDismiss()
            }
            else {
              validateBudget()
            }
          }
        }
      })
      .ignoresSafeArea(.keyboard, edges: .all)
      .onTapGesture {
        isFieldFocused = false
      }
      .onAppear {
        if isUpdating {
          amountValue = String(recurringPayment.amount)
          budgetValue = budget.amount
          savedDate = recurringPayment.dueDate
        } else {
          budgetValue = budget.amount
        }
      }
      .applyMargins()
      .popup(isPresented: $showError, view: {
        EXToast(type: $errorType)
      }, customize: {
        $0
          .isOpaque(true)
          .type(.floater())
          .position(.top)
          .autohideIn(1.5)
      })
      .sheet(isPresented: $showSchedule) {
        PeriodicitySelectorView(presentation: $showSchedule, selectedPeriodicity: $recurringPayment.schedule)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
      }
      .sheet(isPresented: $showNextDate) {
        DateSelectorView(type: .setRecurrentDate, selectedDate: $recurringPayment.dueDate)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
      }
      .sheet(isPresented: $showCategoryelector) {
        CategorySelectorView(presentation: $showCategoryelector, title: $recurringPayment.categoryName, icon: $recurringPayment.categoryIcon, section: .constant(.other))
          .frame(height: 600)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
          .presentationDragIndicator(.visible)
      }
      .popup(isPresented: $showReminderAlert) {
        EXAlert(type: .createReminder) {
          recurringPayment.isReminder = true
          AnalyticsManager.shared.log(.createdReminder(recurringPayment.name))
          notificationManager.scheduleTriggerNotification(for: recurringPayment)
          createPayment()
          DispatchQueue.main.async {
            showReminderAlert.toggle()
            makeDismiss()
          }
        } secondaryAction: {
          recurringPayment.isReminder = false
          AnalyticsManager.shared.log(.createdReminder(recurringPayment.name))
          createPayment()
          DispatchQueue.main.async {
            showReminderAlert.toggle()
            makeDismiss()
          }
        }
        .applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .position(.bottom)
          .type(.floater(useSafeAreaInset: true))
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(isUpdating ? Appearance.shared.updateTitle : Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
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
    let updateTitle = "Edit recurring payment"
    let textFieldPlaceholder = "What is the recurring payment for?"
    
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
  func recurringTextField() -> some View {
    HStack {
      Text(Locale.current.localizedCurrencySymbol(forCurrencyCode: currencySign) ?? "$")
        .font(.system(.title2, weight: .medium))
      TextField("", text: $amountValue)
        .font(.system(.largeTitle, weight: .medium))
        .tint(.clear)
        .multilineTextAlignment(.leading)
        .disabled(true)
      
      Spacer()
      
      Button {
        amountValue.removeLast()
        if amountValue.isEmpty {
          amountValue = "0.0"
        }
      } label: {
        Source.Images.System.remove
          .padding(10)
          .background(Color.backgroundGrey)
          .cornerRadius(20)
      }
      .buttonStyle(EXPlainButtonStyle())
      .disabled(amountValue == "0.0")
    }
  }
  
  @ViewBuilder
  func budgetSection() -> some View {
    EXBaseCard {
      VStack(alignment: .leading) {
        Text("\(budgetValue.formattedAsCurrency(with: currencySign))")
          .font(.title3Semibold)
          .foregroundColor(.primaryGreen)
        Text("Budget remaining")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// MARK: - Realm Functions
extension AddRecurrentPaymentView {
  func createPayment() {
    AnalyticsManager.shared.log(.createPayment(recurringPayment.name, Double(amountValue) ?? 0))
    recurringPayment.amount = Double(amountValue) ?? 0
    try? realm.write {
      realm.add(recurringPayment)
    }
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount -= recurringPayment.amount
      }
    }
  }
  
  func updatePayment() {
    AnalyticsManager.shared.log(.editPayment)
    var difference: Double = 0
    if let newTransaction = recurringPayment.thaw(), let realm = newTransaction.realm {
      try? realm.write {
        difference = newTransaction.amount - (Double(amountValue) ?? 0)
        newTransaction.amount = Double(amountValue) ?? 0
      }
    }
    print(difference)
    
    if let newBudget = budget.thaw(), let realm = newBudget.realm {
      try? realm.write {
        newBudget.amount += difference
      }
    }
  }
}


// MARK: - Helper Functions
extension AddRecurrentPaymentView {
  func validateBudget() {
    if Double(amountValue) ?? 0 > budgetValue {
      errorType = .budgetExceed
      showError.toggle()
      return
    } else if Double(amountValue) ?? 0 == 0 {
      errorType = .zeroAmount
      showError.toggle()
      return
    } else if recurringPayment.name.isEmpty {
      errorType = .emptyName
      showError.toggle()
      return
    } else if recurringPayment.dueDate < Date() {
      errorType = .pastDate
      showError.toggle()
      if isUpdating {
        if let newPayment = recurringPayment.thaw(), let realm = newPayment.realm {
          try? realm.write {
            newPayment.dueDate = savedDate
          }
        }
      }
      return
    } else {
      if isUpdating {
        notificationManager.deleteNotification(for: recurringPayment)
        updatePayment()
        notificationManager.scheduleTriggerNotification(for: recurringPayment)
        makeDismiss()
      } else {
        showReminderAlert.toggle()
      }
    }
  }
}
