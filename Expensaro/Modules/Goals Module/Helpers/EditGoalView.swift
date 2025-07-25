//
//  EditGoalView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct EditGoalView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @State private var amountValue: String = "0.0"
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Realm
  @ObservedRealmObject var goal: Goal
  
  // MARK: Variables
  @State private var savedDate = Date()
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Error
  @State private var errorType = EXToasts.none
  
  // MARK: Presentation
  @State private var showDateSelector = false
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView(showsIndicators: false) {
          VStack(spacing: 20) {
            goalTextField()
            
            Button(action: {
              showDateSelector.toggle()
            }) {
              EXLargeSelector(text: .constant(Source.Functions.showString(from: goal.dueDate)), icon: .constant(.image(Source.Images.System.calendarYear)), header: "Goal due date", rightIcon: "swipeDown")
            }
            .buttonStyle(EXPlainButtonStyle())
          }
          .applyMargins()
          .padding(.top, 20)
        }
        
        EXNumberKeyboard(textValue: $amountValue) {
          validateGoal()
        }
        .applyMargins()
      })
      .onAppear {
        amountValue = String(goal.finalAmount)
        savedDate = goal.dueDate
      }
      .sheet(isPresented: $showDateSelector, content: {
        DateSelectorView(type: .updateGoalDate, selectedDate: $goal.dueDate)
          .frame(height: 400)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
      })
      .popup(isPresented: $showError, view: {
        EXToast(type: $errorType)
      }, customize: {
        $0
          .isOpaque(true)
          .type(.floater())
          .position(.top)
          .autohideIn(1.5)
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
            .padding(.top)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .foregroundColor(.black)
              .padding(.top)
          }
        }
      }
    }
  }
}

struct EditGoalView_Previews: PreviewProvider {
  static var previews: some View {
    EditGoalView(goal: Source.DefaultData.sampleGoals[0])
  }
}


// MARK: - Appearance
extension EditGoalView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Edit goal"
    
    let closeIcon = Source.Images.Navigation.close
    let timerIcon = Source.Images.System.timer
  }
}

// MARK: - Helper Views
extension EditGoalView {
  @ViewBuilder
  func goalTextField() -> some View {
    HStack {
      Text(Locale.current.localizedCurrencySymbol(forCurrencyCode: currencySign) ?? "$")
        .font(.system(.title2, weight: .medium))
      TextField("", text: $amountValue)
        .font(.system(.largeTitle, weight: .medium))
        .tint(.clear)
        .multilineTextAlignment(.leading)
      
      Spacer()
      
      Button {
        amountValue.removeLast()
        if amountValue.isEmpty { amountValue = "0.0" }
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
}

// MARK: - Realm Functions
extension EditGoalView {
  func updateGoal() {
    AnalyticsManager.shared.log(.editGoal)
    if let newGoal = goal.thaw(), let realm = newGoal.realm {
      try? realm.write {
        newGoal.finalAmount = Double(amountValue) ?? 0
      }
    }
  }
}

// MARK: - Helper Functions
extension EditGoalView {
  func validateGoal() {
    if goal.dueDate < Date() {
      errorType = .pastDate
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      if let newGoal = goal.thaw(), let goalRealm = newGoal.realm {
        try? goalRealm.write {
          newGoal.dueDate = savedDate
        }
      }
      return
    } else if Double(amountValue) == 0 {
      errorType = .zeroAmount
      showError.toggle()
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      return
    }
    updateGoal()
    makeDismiss()
  }
}
