//
//  GoalsListView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/11/23.
//

import SwiftUI
import ExpensaroUIKit

struct GoalsListView: View {
  @State private var showAddGoalView = false
  var body: some View {
    NavigationView {
      VStack {
        EXEmptyStateWithImage(type: .noGoals, image: Source.Images.EmptyStates.noGoals, buttonIcon: Source.Images.ButtonIcons.add, action: {
          showAddGoalView.toggle()
        }).applyMargins()
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 24))
            .padding(.bottom, 20)
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

// MARK: - Apperance
extension GoalsListView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Goals"
  }
}
