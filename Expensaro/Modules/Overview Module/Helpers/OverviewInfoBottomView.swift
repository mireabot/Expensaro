//
//  OverviewInfoBottomView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/25/23.
//

import SwiftUI
import ExpensaroUIKit

struct OverviewInfoBottomView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Image("topCategoryInfo")
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.backgroundGrey)
        .cornerRadius(12)
      Text("Keep track of your spendings progress")
        .font(.mukta(.semibold, size: 17))
      Text("We will calculate the percentage of changes in spending at the end of this month and the previous month")
        .font(.mukta(.regular, size: 15))
        .foregroundColor(.darkGrey)
        .multilineTextAlignment(.leading)
    }
    .applyMargins()
  }
}

struct OverviewInfoBottomView_Previews: PreviewProvider {
  static var previews: some View {
    OverviewInfoBottomView()
  }
}

//MARK: - Appearance
extension OverviewInfoBottomView {
  struct Appearance {
    static let shared = Appearance()
    
    let closeIcon = Source.Images.Navigation.close
  }
}
