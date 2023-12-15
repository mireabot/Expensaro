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
  let onSubmit: () -> Void
  let onDeny: () -> Void
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 5, content: {
          Text("Do you want to create reminder?")
            .font(.system(.title3, weight: .bold))
          Text("Receive a push notification one day prior to your payment")
            .font(.system(.subheadline, weight: .medium))
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
            onDeny()
          }, label: {
            Text("No, thank you")
              .font(.system(.headline, weight: .semibold))
          })
          .buttonStyle(EXSecondaryPrimaryButtonStyle(showLoader: .constant(false)))
          Button(action: {
            isPresented.toggle()
            onSubmit()
          }, label: {
            Text("Yes, I'm in")
              .font(.system(.headline, weight: .semibold))
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
  CreateReminderView(isPresented: .constant(true), onSubmit: {}, onDeny: {})
}
