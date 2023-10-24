//
//  EXErrorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/23/23.
//

import SwiftUI

struct EXErrorView: View {
  @Binding var type: EXErrors
  var body: some View {
    HStack {
      Source.Images.System.alertError
        .foregroundColor(.red)
      Text("\(type.text)")
        .font(.mukta(.medium, size: 17))
        .foregroundColor(.red)
    }
    .frame(maxWidth: .infinity)
    .padding(10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.5)
        .stroke(Color.border, lineWidth: 1)
    )
    .applyMargins()
  }
}
