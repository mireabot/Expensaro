//
//  GoalsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/11/23.
//

import SwiftUI
import ExpensaroUIKit

struct GoalsListView: View {
  var body: some View {
    NavigationView {
      ZStack {
        emptyGoalsView()
        ScrollView(.vertical, showsIndicators: false) {
          
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Goals")
            .font(.mukta(.medium, size: .title))
        }
      }
    }
  }
}

struct GoalsListView_Previews: PreviewProvider {
  static var previews: some View {
    GoalsListView()
  }
}

private extension GoalsListView {
  @ViewBuilder
  func emptyGoalsView() -> some View {
    VStack {
      Spacer()
      
      Spacer()
    }.applyMargins()
  }
}
