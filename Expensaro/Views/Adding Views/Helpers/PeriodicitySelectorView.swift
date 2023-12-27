//
//  PeriodicitySelectorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit

struct PeriodicitySelectorView: View {
  @Binding var presentation: Bool
  @Binding var selectedPeriodicity: RecurringSchedule
  let schedule = RecurringSchedule.allCases
  var body: some View {
    VStack {
      HStack {
        Text("Select payment periodicity")
          .font(.title3Semibold)
        Spacer()
      }
      .padding(.bottom, 10)
      ForEach(schedule, id: \.self) { data in
        Button {
          DispatchQueue.main.async {
            withAnimation(.spring) {
              presentation = false
              selectedPeriodicity = data
            }
          }
        } label: {
          EXSmallCard(title: data.title, image: "calendarYear")
        }
        .buttonStyle(EXPlainButtonStyle())
      }
    }
    .applyMargins()
  }
}

struct PeriodicitySelectorView_Previews: PreviewProvider {
  static var previews: some View {
    PeriodicitySelectorView(presentation: .constant(false), selectedPeriodicity: .constant(RecurringSchedule.everyWeek))
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
