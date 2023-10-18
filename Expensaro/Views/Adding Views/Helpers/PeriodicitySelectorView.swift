//
//  PeriodicitySelectorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit

struct PeriodicitySelectorView: View {
  @Environment(\.dismiss) var makeDismiss
  @Binding var selectedPeriodicity: RecurringSchedule
  let schedule = RecurringSchedule.allCases
  var body: some View {
    NavigationView {
      List {
        VStack {
          ForEach(schedule, id: \.self) { data in
            Button {
              selectedPeriodicity = data
              makeDismiss()
            } label: {
              EXCategoryCell(icon: Source.Images.System.calendarYear, title: data.title)
            }
            .buttonStyle(EXPlainButtonStyle())
          }
        }
        .listRowSeparator(.hidden)
      }
      .listStyle(.inset)
      .background(.white)
      .scrollDisabled(true)
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

struct PeriodicitySelectorView_Previews: PreviewProvider {
  static var previews: some View {
    PeriodicitySelectorView(selectedPeriodicity: .constant(RecurringSchedule.everyWeek))
  }
}

//MARK: - Appearance
extension PeriodicitySelectorView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Select payment periodicity"
    
    let closeIcon = Source.Images.Navigation.close
    let periodicitySet : [(Image, String)] = [
      (Source.Images.System.calendarYear, "Every week"),
      (Source.Images.System.calendarYear, "Every month"),
      (Source.Images.System.calendarYear, "Every 3 months"),
      (Source.Images.System.calendarYear, "Every year"),
    ]
  }
}
