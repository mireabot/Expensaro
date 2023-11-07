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
    HStack(alignment: .center, spacing: 12) {
        Source.Images.System.alertError
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(Color(red: 0.345, green: 0, blue: 0.008))
      VStack(alignment: .leading, spacing: -5, content: {
        Text("Watch out!").font(.mukta(.semibold, size: 17)).foregroundColor(.alertDarkRed)
        
        Text("\(type.text)")
          .font(.mukta(.semibold, size: 17))
          .foregroundColor(.alertRed)
        HStack {
          
        }
      })
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.alertRedOpacity)
    .cornerRadius(12)
    .applyMargins()
  }
}

#Preview {
  VStack {
    ForEach(EXErrors.allCases, id: \.self) { type in
      EXErrorView(type: .constant(type))
    }
  }
}
