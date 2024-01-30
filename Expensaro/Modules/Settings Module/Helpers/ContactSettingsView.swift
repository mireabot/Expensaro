//
//  ContactSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/23/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView

struct ContactSettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var message: String = ""
  @State private var email: String = ""
  @FocusState private var isFocused: Bool
  
  // MARK: Presentation
  @State private var showToast = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 40) {
          VStack(alignment: .leading, spacing: 0) {
            Text("What's on your mind?")
              .font(.system(.headline, weight: .regular))
              .foregroundColor(.black)
            EXResizableTextField(message: $message, characterLimit: 1500)
              .focused($isFocused)
              .multilineSubmitEnabled(for: $message)
          }
          
          VStack(alignment: .leading, spacing: 5) {
            EXTextField(text: $email, header: "Contact email", placeholder: "What's your email")
              .keyboardType(.emailAddress)
              .focused($isFocused)
            Text("Just so we can get back to you. We won't use your email for anything else.")
              .font(.system(.footnote, weight: .regular))
              .foregroundColor(.darkGrey)
          }
        }
        .padding(.top, 20)
        .applyMargins()
        .popup(isPresented: $showToast, view: {
          EXToast(type: .constant(.feebackSent))
        }, customize: {
          $0
            .isOpaque(true)
            .type(.floater())
            .position(.top)
            .autohideIn(1.5)
            .dismissCallback {
              AnalyticsManager.shared.log(.sendFeedback(.now, message, email))
              router.nav?.popViewController(animated: true)
            }
        })
      }
      .onTapGesture {
        isFocused = false
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showToast.toggle()
          } label: {
            Appearance.shared.submitIcon
              .foregroundColor(message.isEmpty || email.isEmpty ? .darkGrey : .primaryGreen)
          }
          .disabled(message.isEmpty || email.isEmpty)
        }
      }
    }
  }
}

struct ContactSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    ContactSettingsView()
  }
}

// MARK: - Appearance
extension ContactSettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Contact"
    
    let backIcon = Source.Images.Navigation.back
    let submitIcon = Source.Images.ButtonIcons.send
  }
}
