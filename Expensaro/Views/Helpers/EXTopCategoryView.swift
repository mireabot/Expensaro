//
//  EXTopCategoryView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/26/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXTopCategoryView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack(alignment: .center) {
        Text("Top Category")
          .font(.system(.subheadline, weight: .semibold))
          .foregroundColor(.primaryGreen)
        Spacer()
        Source.Images.Navigation.redirect
          .foregroundColor(.darkGrey)
      }
      VStack(alignment: .leading, spacing: 5) {
        Text("Amazon")
          .font(.system(.title2, weight: .bold))
        Text("You have spent $1500 on this category")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.white)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .inset(by: 0.5)
        .stroke(Color.border, lineWidth: 1)
    )
  }
}

#Preview {
  EXTopCategoryView().applyMargins()
}
