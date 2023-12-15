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
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.alertDarkGreen)
      } else {
        Source.Images.System.alertError
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.alertDarkRed)
      }
      VStack(alignment: .leading, spacing: 3, content: {
        Text(type.isSuccess ? "All great!" : "Watch out!")
          .font(.system(.title3, weight: .semibold))
          .foregroundColor(type.isSuccess ? .alertDarkGreen : .alertDarkRed)
        
        Text("\(type.text)")
          .font(.system(.headline, weight: .medium))
          .foregroundColor(type.isSuccess ? .alertGreen : .alertRed)
      })
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(type.isSuccess ? Color.alertGreenOpacity : Color.alertRedOpacity)
    .cornerRadius(16)
    .applyMargins()
  }
}

#Preview {
  EXToast(type: .constant(.emptyName))
}
