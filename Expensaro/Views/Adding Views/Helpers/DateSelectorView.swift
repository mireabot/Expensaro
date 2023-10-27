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
  @State private var date: Date = .now
  @Binding var selectedDate: Date
  var body: some View {
    NavigationView {
      ScrollView {
        DatePicker(
          "Start Date",
          selection: $date,
          displayedComponents: [.date]
        )
        .tint(.primaryGreen)
        .datePickerStyle(.graphical)
      }
      .scrollDisabled(true)
      .applyMargins()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(type.title)
            .font(.mukta(.medium, size: 17))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            selectedDate = date
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
        return "Set pay date"
      case .updateGoalDate:
        return "Set new completion date"
      case .updateTransaction:
        return "Set new transaction date"
      }
    }
  }
}
