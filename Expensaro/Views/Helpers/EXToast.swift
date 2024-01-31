//
//  EXErrorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/23/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXToast: View {
  @Binding var type: EXToasts
  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      if type.isSuccess {
        Source.Images.System.alertSuccess
          .foregroundColor(.alertDarkGreen)
      } else {
        Source.Images.System.alertError
          .foregroundColor(.alertDarkRed)
      }
      VStack(alignment: .leading, spacing: 3, content: {
        Text(type.isSuccess ? "All good!" : "Watch out!")
          .font(.headlineBold)
          .foregroundColor(type.isSuccess ? .alertDarkGreen : .alertDarkRed)
        
        Text("\(type.text)")
          .font(.subheadlineMedium)
          .foregroundColor(type.isSuccess ? .alertGreen : .alertRed)
      })
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(type.isSuccess ? Color.alertGreenOpacity : Color.alertRedOpacity)
    .cornerRadius(12)
    .applyMargins()
  }
}

#Preview {
  EXToast(type: .constant(.emptyName))
}
