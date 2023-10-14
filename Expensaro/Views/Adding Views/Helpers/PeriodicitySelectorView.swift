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
  @Binding var selectedPeriodicity: String
  @Binding var newDate: Date
  var body: some View {
    NavigationView {
      List {
        VStack {
          EXCategoryCell(icon: Appearance.shared.periodicitySet[0].0, title: Appearance.shared.periodicitySet[0].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[0].1
              newDate = getSampleDate(offset: 7)
              makeDismiss()
            }
          EXCategoryCell(icon: Appearance.shared.periodicitySet[1].0, title: Appearance.shared.periodicitySet[1].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[1].1
              newDate = getSampleDate(offset: 30)
              makeDismiss()
            }
          EXCategoryCell(icon: Appearance.shared.periodicitySet[2].0, title: Appearance.shared.periodicitySet[2].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[2].1
              newDate = getSampleDate(offset: 90)
              makeDismiss()
            }
          EXCategoryCell(icon: Appearance.shared.periodicitySet[3].0, title: Appearance.shared.periodicitySet[3].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[3].1
              newDate = getSampleDate(offset: 365)
              makeDismiss()
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
    PeriodicitySelectorView(selectedPeriodicity: .constant(""), newDate: .constant(Date()))
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
