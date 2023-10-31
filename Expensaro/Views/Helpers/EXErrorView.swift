//
//  EXErrorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/23/23.
//

import SwiftUI
import ExpensaroUIKit

struct EXErrorView: View {
  @Binding var type: EXErrors
  var body: some View {
    HStack {
      Text("\(type.text)")
        .font(.mukta(.medium, size: 17))
        .foregroundColor(.alertRedOpacity)
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .center)
    .background(Color.alertRed)
    .cornerRadius(12)
    .applyMargins()
  }
}

#Preview {
  EXErrorView(type: .constant(.emptyName))
}
