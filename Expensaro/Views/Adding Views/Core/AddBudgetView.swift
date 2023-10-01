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
  let type: ScreenType
  @FocusState private var budgetFieldFocused: Bool
  @State private var budgetValue: String = ""
  @State var detentHeight: CGFloat = 0
  
  @State private var showSuccess = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          EXTextFieldWithCurrency(text: $budgetValue)
            .focused($budgetFieldFocused)
          if type == .updateBudget {
            Text(Appearance.shared.infoText)
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
          }
        }
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
          Text(type == .addBudget ? Appearance.shared.addBudgetButtonText : Appearance.shared.updateBudgetButtonText)
            .font(.mukta(.semibold, size: 17))
        }
        .applyMargins()
        .padding(.bottom, 15)
        .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
        
      })
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(type == .addBudget ? Appearance.shared.addBudgetTitle : Appearance.shared.updateBudgetTitle)
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
    AddBudgetView(type: .addBudget)
  }
}

// MARK: - Apperance
extension AddBudgetView {
  struct Appearance {
    static let shared = Appearance()
    let addBudgetTitle = "Add budget"
    let addBudgetButtonText = "Add budget"
    
    let updateBudgetTitle = "Update your budget"
    let updateBudgetButtonText = "Update budget"
    
    let infoText = "Enter amount which you want to add to your current budget"
    
    let closeIcon = Source.Images.Navigation.close
  }
}

extension AddBudgetView {
  enum ScreenType {
    case addBudget
    case updateBudget
  }
}
