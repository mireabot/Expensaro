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
  @State private var amountValue: String = ""
  @State private var goalName: String = ""
  @State private var goalCategory: String = "Travel"
  @State private var goalDue: String = Source.Functions.showString(from: .now)
  
  @State private var showInitPaymentSheet = false
  @State private var showDateSheet = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          EXTextField(text: $goalName, placeholder: Appearance.shared.placeholder).focused($isFieldFocused)
          EXLargeCurrencyTextField(text: $amountValue, bottomView: Appearance.shared.bottomView).focused($isFieldFocused)
          EXLargeSelector(text: $goalDue, icon: .constant(Appearance.shared.timerIcon), buttonText: "Change", action: {
            showDateSheet.toggle()
          })
        }.padding(.top, 16)
      }
      .onTapGesture {
        DispatchQueue.main.async {
          isFieldFocused = false
        }
      }
      .applyMargins()
      .sheet(isPresented: $showDateSheet, content: {
        DateSelectorView(title: Appearance.shared.dateSelectorTitle, selectedDate: $goalDue)
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
    let dateSelectorTitle = "Set goal date"
    
    let closeIcon = Source.Images.Navigation.close
    let timerIcon = Source.Images.System.timer
    
    var bottomView: any View {
      Text("Budget for your goal")
        .font(.mukta(.regular, size: 15))
        .foregroundColor(.primaryGreen)
    }
  }
}
