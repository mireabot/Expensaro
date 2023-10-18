//
//  AddGoalView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit

struct AddGoalView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var isFieldFocused: Bool
  @State private var amountValue: String = "0.0"
  @State private var goalName: String = ""
  @State private var goalDue: Date = .now
  
  @State private var showInitPaymentSheet = false
  @State private var showDateSheet = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          EXTextField(text: $goalName, placeholder: Appearance.shared.placeholder)
            .keyboardType(.alphabet)
            .focused($isFieldFocused)
          EXLargeCurrencyTextField(value: $amountValue, bottomView: Appearance.shared.bottomView)
            .keyboardType(.alphabet)
            .focused($isFieldFocused)
          VStack(alignment: .leading, spacing: 5) {
            Text(Appearance.shared.infoText)
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
//            EXLargeSelector(text: $goalDue, icon: .constant("timer"), buttonText: "Change", action: {
//              showDateSheet.toggle()
//            })
          }
        }
        .padding(.top, 16)
        
      }
      .onTapGesture {
        isFieldFocused = false
      }
      .applyMargins()
      .sheet(isPresented: $showDateSheet, content: {
        DateSelectorView(type: .setGoalDate, selectedDate: $goalDue)
          .presentationDetents([.medium])
      })
      .safeAreaInset(edge: .bottom, content: {
        Button {
          
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

struct AddGoalView_Previews: PreviewProvider {
  static var previews: some View {
    AddGoalView()
  }
}

//MARK: - Appearance
extension AddGoalView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add goal"
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
