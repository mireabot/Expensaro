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
    EXBaseCard {
      VStack(alignment: .leading, spacing: 5) {
        HStack(alignment: .center) {
          Text("Top Category")
            .font(.subheadlineSemibold)
            .foregroundColor(.primaryGreen)
          Spacer()
          Source.Images.Navigation.redirect
            .foregroundColor(.darkGrey)
        }
        VStack(alignment: .leading, spacing: 3) {
          Text("Shopping")
            .font(.title2Bold)
          Text("You have spent $1500 on this category")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
        }
      }
    }
  }
}

#Preview {
  EXTopCategoryView().applyMargins()
}
