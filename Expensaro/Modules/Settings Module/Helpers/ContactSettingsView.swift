//
//  ContactSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/23/23.
//

import SwiftUI
import ExpensaroUIKit

struct ContactSettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var contactType: String = ""
  @State private var message: String = ""
  @State private var email: String = ""
  @FocusState private var isFocused: Bool
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 40) {
          EXSegmentControl(currentTab: $contactType, type: .contactReason)
          
          VStack(alignment: .leading, spacing: 0) {
            Text("What's on your mind?")
              .font(.mukta(.regular, size: 17))
              .foregroundColor(.black)
            EXResizableTextField(message: $message, characterLimit: 1500)
              .keyboardType(.alphabet)
              .focused($isFocused)
          }
          
          VStack(alignment: .leading, spacing: 5) {
            EXTextField(text: $email, placeholder: "What's your email")
              .keyboardType(.emailAddress)
              .focused($isFocused)
            Text("Just so we can get back to you. We won't use your email for anything else.")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
          }
        }
        .padding(.top, 20)
        .applyMargins()
      }
      .onTapGesture {
        isFocused = false
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
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
