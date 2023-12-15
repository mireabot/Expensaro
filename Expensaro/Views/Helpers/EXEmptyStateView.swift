//
//  EXEmptyStateView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/3/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXEmptyStateView: View {
  var type: EXEmptyStates
  var isCard: Bool?
  var body: some View {
    if isCard ?? true {
      VStack(alignment: .leading, spacing: 5, content: {
        type.image
          .resizable()
          .frame(width: 24, height: 24)
          .foregroundColor(.primaryGreen)
        Text("\(type.title) \(type.text)")
          .font(.system(.headline, weight: .semibold))
          .frame(maxWidth: .infinity, alignment: .leading)
      })
      .padding(14)
      .background(Color.backgroundGrey)
      .cornerRadius(12)
    } else {
      VStack(alignment: .center, spacing: 5) {
        type.image
          .resizable()
          .frame(width: 120, height: 120)
        VStack(spacing: 5) {
          type.title
          Text(type.text)
            .font(.system(.headline, weight: .semibold))
            .foregroundColor(.darkGrey)
        }
      }
    }
  }
}

#Preview {
  EXEmptyStateView(type: .noCustomCategories, isCard: true).applyMargins()
}
