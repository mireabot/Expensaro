//
//  AddGoalView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct AddGoalView: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  @State private var amountValue: String = "0.0"
  
  //MARK: Realm
  @Environment(\.realm) var realm
  @ObservedRealmObject var goal: Goal
  
  // MARK: Presentation
  @State private var showInitPaymentSheet = false
  @State private var showDateSheet = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          EXTextField(text: $goal.name, placeholder: Appearance.shared.placeholder)
            .keyboardType(.alphabet)
            .focused($isFieldFocused)
          goalTextField()
            .inputView {
              EXNumberKeyboard(textValue: $amountValue) {
                isFieldFocused = false
              }
              .applyMargins()
              .padding(.bottom, 15)
            }
            .focused($isFieldFocused)
          VStack(alignment: .leading, spacing: 5) {
            Text(Appearance.shared.infoText)
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
            EXLargeSelector(text: .constant(Source.Functions.showString(from: goal.dueDate)), icon: .constant("timer"), buttonText: "Change") {
              showDateSheet.toggle()
            }
          }
        }
        .padding(.top, 16)
        
      }
      .onTapGesture {
        isFieldFocused = false
      }
      .applyMargins()
      .sheet(isPresented: $showDateSheet, content: {
        DateSelectorView(type: .setGoalDate, selectedDate: $goal.dueDate)
          .presentationDetents([.medium])
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
        ToolbarItem(placement: .bottomBar) {
          Button {
            createGoal {
              makeDismiss()
            }
          } label: {
            Text(Appearance.shared.buttonText)
              .font(.mukta(.semibold, size: 17))
          }
          .padding(.bottom, 15)
          .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
          .disabled(goal.name.isEmpty || amountValue == "0.0")
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
    let placeholder = "Ex.Trip to Paris"
    let buttonText = "Create goal"
    let infoText = "Set a goal completion date"
    
    let closeIcon = Source.Images.Navigation.close
    let timerIcon = Source.Images.System.timer
    
    var bottomView: any View {
      Text("Budget for your goal")
        .font(.mukta(.regular, size: 15))
        .foregroundColor(.primaryGreen)
    }
  }
}

// MARK: - Helper Views
extension AddGoalView {
  @ViewBuilder
  func goalTextField() -> some View {
    HStack {
      Text("$")
        .font(.mukta(.medium, size: 24))
      TextField("", text: $amountValue)
        .font(.mukta(.medium, size: 40))
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
extension AddGoalView {
  func createGoal(completion: @escaping() -> Void) {
    goal.finalAmount = Double(amountValue) ?? 0
    try? realm.write {
      realm.add(goal)
    }
    completion()
  }
}
