//
//  DateSelectorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit

struct DateSelectorView: View {
  @Environment(\.dismiss) var makeDismiss
  let type: SelectorType
  @Binding var selectedDate: Date
  var body: some View {
    NavigationView(content: {
      VStack {
        DatePicker(
          "Start Date",
          selection: $selectedDate,
          displayedComponents: [.date]
        )
        .tint(.primaryGreen)
        .datePickerStyle(.graphical)
        .frame(height: 320)
      }
      .applyMargins()
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.white, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text(type.title)
            .font(.title3Semibold)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            makeDismiss()
          }, label: {
            Source.Images.Navigation.close
              .foregroundColor(.black)
          })
        }
      }
    })
  }
}

struct DateSelectorView_Previews: PreviewProvider {
  static var previews: some View {
    DateSelectorView(type: .updateGoalDate, selectedDate: .constant(Date()))
  }
}

//MARK: - Appearance
extension DateSelectorView {
  struct Appearance {
    static let shared = Appearance()
    
    let closeIcon = Source.Images.Navigation.checkmark
  }
}

// MARK: - Helper Enums
extension DateSelectorView {
  enum SelectorType {
    case setGoalDate
    case setRecurrentDate
    case updateGoalDate
    case updateTransaction
    
    var title: String {
      switch self {
      case .setGoalDate:
        return "Set goal completion date"
      case .setRecurrentDate:
        return "Set payment due date"
      case .updateGoalDate:
        return "Set new completion date"
      case .updateTransaction:
        return "Set new transaction date"
      }
    }
  }
}
