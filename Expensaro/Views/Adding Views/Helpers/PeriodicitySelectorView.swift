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
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 15) {
          EXCategoryListCell(icon: Appearance.shared.periodicitySet[0].0, title: Appearance.shared.periodicitySet[0].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[0].1
              makeDismiss()
            }
          EXCategoryListCell(icon: Appearance.shared.periodicitySet[1].0, title: Appearance.shared.periodicitySet[1].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[1].1
              makeDismiss()
            }
          EXCategoryListCell(icon: Appearance.shared.periodicitySet[2].0, title: Appearance.shared.periodicitySet[2].1)
            .onTapGesture {
              selectedPeriodicity = Appearance.shared.periodicitySet[2].1
              makeDismiss()
            }
        }
        .applyMargins()
        .padding(.top, 20)
      }
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
    PeriodicitySelectorView(selectedPeriodicity: .constant(""))
  }
}

//MARK: - Appearance
extension PeriodicitySelectorView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Select payment periodicity"
    
    let closeIcon = Source.Images.Navigation.close
    let periodicitySet : [(Image, String)] = [
      (Source.Images.System.calendarWeek, "Every week"),
      (Source.Images.System.calendarMonth, "Every month"),
      (Source.Images.System.calendarYear, "Every year"),
    ]
  }
}
