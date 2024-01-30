//
//  AddGoalView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import PopupView

struct AddGoalView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  @State private var amountValue: String = "0.0"
  @AppStorage("currencySign") private var currencySign = "USD"
  
  //MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var goal: Goal
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  
  var currentBudget: Budget {
    budget.first ?? Budget()
  }
  
  // MARK: Variables
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Error
  @State private var errorType = EXToasts.none
  
  // MARK: Presentation
  @State private var showInitPaymentSheet = false
  @State private var showDateSheet = false
  @State private var showError = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom, content: {
        ScrollView {
          VStack(spacing: 20) {
            goalTextField()
            
            EXTextField(text: $goal.name, header: "Goal name", placeholder: Appearance.shared.placeholder)
              .focused($isFieldFocused)
            
            Button(action: { showDateSheet.toggle() }, label: {
              EXLargeSelector(text: .constant(Source.Functions.showString(from: goal.dueDate)), icon: .constant(.image(Source.Images.System.timer)), header: "Goal completion date", rightIcon: "swipeDown")
            })
            .buttonStyle(EXPlainButtonStyle())
            
            if currentBudget.initialAmount != 0 {
              GoalEstimatorView(goalManager: .init(), goalInfo: (currentBudget.initialAmount, Double(amountValue) ?? 0, goal.daysLeft))
            }
          }
          .padding(.top, 25)
        }
        .applyBounce()
        
        EXNumberKeyboard(textValue: $amountValue) {
          validateGoal()
        }
      })
      .ignoresSafeArea(.keyboard, edges: .all)
      .onTapGesture {
        isFieldFocused = false
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
      .sheet(isPresented: $showDateSheet) {
        DateSelectorView(type: .setGoalDate, selectedDate: $goal.dueDate)
          .frame(height: 400)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
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

struct AddGoalView_Previews: PreviewProvider {
  static var previews: some View {
    AddGoalView(goal: Goal())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

//MARK: - Appearance
extension AddGoalView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Create goal"
    let placeholder = "What do you want to save for?"
    let buttonText = "Create goal"
    let infoText = "Set a goal completion date"
    
    let closeIcon = Source.Images.Navigation.close
    let timerIcon = Source.Images.System.timer
    
    var bottomView: any View {
      Text("Budget for your goal")
        .font(.system(.subheadline, weight: .regular))
        .foregroundColor(.primaryGreen)
    }
  }
}

// MARK: - Helper Views
extension AddGoalView {
  @ViewBuilder
  func goalTextField() -> some View {
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
extension AddGoalView {
  func createGoal(completion: @escaping() -> Void) {
    AnalyticsManager.shared.log(.createGoal(goal.name, Double(amountValue) ?? 0))
    goal.finalAmount = Double(amountValue) ?? 0
    goal.dateCreated = .now
    try? realm.write {
      realm.add(goal)
    }
    completion()
  }
}


// MARK: - Helper Functions
extension AddGoalView {
  func validateGoal() {
    if goal.name.isEmpty {
      errorType = .emptyName
      showError.toggle()
    } else if Double(amountValue) ?? 0 == 0 {
      errorType = .zeroAmount
      showError.toggle()
    } else if goal.dueDate < Date() {
      errorType = .pastDate
      showError.toggle()
      return
    } else {
      createGoal {
        makeDismiss()
      }
    }
  }
}
