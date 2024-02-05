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
    ViewThatFits(in: .vertical) {
      VStack(alignment: .leading) {
        HStack {
          Text(Appearance.shared.title)
            .font(.title3Semibold)
          Spacer()
          Button(action: {
            presentation = false
          }, label: {
            Source.Images.Navigation.close
              .foregroundColor(.black)
          })
        }
        .applyMargins()
        .padding(.top, 16)
        
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
          ForEach(schedule, id: \.self) { data in
            Button {
              presentation = false
              selectedPeriodicity = data
            } label: {
              EXSelectCell(title: data.title, condition: selectedPeriodicity.title == data.title)
            }
            .buttonStyle(EXPlainButtonStyle())
          }
        }
        .applyMargins()
      }
    }
    .background(.white)
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
  }
}
