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
          .font(.mukta(.medium, size: 15))
          .foregroundColor(.primaryGreen)
        Spacer()
        Source.Images.Navigation.redirect
          .foregroundColor(.darkGrey)
      }
      VStack(alignment: .leading, spacing: -4) {
        Text("Amazon")
          .font(.mukta(.bold, size: 24))
        Text("You have spent $1500 on this category")
          .font(.mukta(.regular, size: 15))
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
