//
//  CreateReminderView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/9/23.
//

import SwiftUI
import ExpensaroUIKit

struct CreateReminderView: View {
  @Binding var isPresented: Bool
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 0, content: {
          Text("Do you want to create reminder?")
            .font(.mukta(.bold, size: 20))
          Text("Receive a push notification one day prior to your payment")
            .font(.mukta(.medium, size: 15))
            .foregroundColor(Color.darkGrey)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 40)
      }
      .applyBounce()
      .applyMargins()
      .safeAreaInset(edge: .bottom, content: {
        HStack {
          Button(action: {
            isPresented.toggle()
          }, label: {
            Text("No, thank you")
              .font(.mukta(.semibold, size: 17))
          })
          .buttonStyle(EXSecondaryPrimaryButtonStyle(showLoader: .constant(false)))
          Button(action: {}, label: {
            Text("Yes, I'm in")
              .font(.mukta(.semibold, size: 17))
          })
          .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
        }
        .applyMargins()
        .padding(.bottom, 10)
      })
    }
  }
}

#Preview {
  CreateReminderView(isPresented: .constant(true))
}
