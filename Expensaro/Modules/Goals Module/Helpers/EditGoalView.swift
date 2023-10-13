//
//  EditGoalView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/23.
//

import SwiftUI
import ExpensaroUIKit

struct EditGoalView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  var selectedGoal: Goal
  @State private var goalAmount: Double = 0
  @State private var goalDue: String = Source.Functions.showString(from: .now)
  
  @State private var showDateSelector = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 20) {
          VStack(spacing: 5) {
            Text("Enter new budget for goal")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
              .frame(maxWidth: .infinity, alignment: .leading)
            EXTextFieldWithCurrency(value: $goalAmount)
              .focused($isFieldFocused)
          }
          
          VStack(spacing: 5) {
            Text("Select new goal due date")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
              .frame(maxWidth: .infinity, alignment: .leading)
            EXLargeSelector(text: $goalDue, icon: .constant("timer"), buttonText: "Change", action: {
              showDateSelector.toggle()
            })
          }
        }
        .applyMargins()
        .padding(.top, 20)
      }
      .onAppear {
        goalAmount = Double(selectedGoal.goalAmount)
        goalDue = Source.Functions.showString(from: selectedGoal.goalDate)
      }
      .onTapGesture {
        isFieldFocused = false
      }
      .sheet(isPresented: $showDateSelector, content: {
        DateSelectorView(type: .updateGoalDate, selectedDate: $goalDue)
          .presentationDetents([.medium])
      })
      .interactiveDismissDisabled()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
            .padding(.top)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .foregroundColor(.black)
              .padding(.top)
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            
          } label: {
            Appearance.shared.saveIcon
              .foregroundColor(.primaryGreen)
              .padding(.top)
          }
        }
      }
    }
  }
}

struct EditGoalView_Previews: PreviewProvider {
  static var previews: some View {
    EditGoalView(selectedGoal: Goal.sampleGoals[2])
  }
}


// MARK: - Appearance
extension EditGoalView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Edit goal"
    
    let closeIcon = Source.Images.Navigation.close
    let timerIcon = Source.Images.System.timer
    let saveIcon = Source.Images.ButtonIcons.save
  }
}
