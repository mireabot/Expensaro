//
//  AddBudgetView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit

struct AddBudgetView: View {
  @Environment(\.dismiss) var makeDismiss
  @FocusState private var budgetFieldFocused: Bool
  @State private var budgetValue: String = ""
  @State var detentHeight: CGFloat = 0
  
  @State private var showSuccess = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXTextFieldWithCurrency(text: $budgetValue)
          .focused($budgetFieldFocused)
      }
      .onTapGesture {
        budgetFieldFocused = false
      }
      .onAppear {
        DispatchQueue.main.async {
          budgetFieldFocused = true
        }
      }
      .applyMargins()
      .scrollDisabled(true)
      .sheet(isPresented: $showSuccess) {
        SuccessBottomAlert(type: .budgetAdded)
          .padding(35)
          .onDisappear {
            makeDismiss()
          }
          .readHeight()
          .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
              self.detentHeight = height
            }
          }
          .presentationDetents([.height(self.detentHeight)])
      }
      .safeAreaInset(edge: .bottom, content: {
        Button {
          showSuccess.toggle()
        } label: {
          Text(Appearance.shared.buttonText)
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 15)
        .buttonStyle(PrimaryButtonStyle())
        
      })
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

struct AddBudgetView_Previews: PreviewProvider {
  static var previews: some View {
    AddBudgetView()
  }
}

// MARK: - Apperance
extension AddBudgetView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Add budget"
    let buttonText = "Add budget"
    
    let closeIcon = Source.Images.Navigation.close
  }
}
