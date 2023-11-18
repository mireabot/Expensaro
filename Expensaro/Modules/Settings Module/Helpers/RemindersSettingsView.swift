//
//  RemindersSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/23/23.
//

import SwiftUI
import ExpensaroUIKit

struct RemindersSettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var reminderOn = UserDefaults.standard.bool(forKey: "notificationsEnabled")
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(alignment: .leading, spacing: 5) {
            Text("General")
              .foregroundColor(.darkGrey)
              .font(.mukta(.regular, size: 13))
            EXToggleCard(type: .notifications, isOn: $reminderOn)
              .onChange(of: reminderOn, perform: { value in
                if value {
                  print("Notifications granted!")
                  DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    UserDefaults.standard.setValue(true, forKey: "notificationsEnabled")
                    UserDefaults.standard.synchronize()
                  }
                } else {
                  print("Notifications not granted!")
                  DispatchQueue.main.async {
                    UIApplication.shared.unregisterForRemoteNotifications()
                    UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
                    UserDefaults.standard.synchronize()
                  }
                }
              })
          }
          
          VStack(alignment: .leading, spacing: 5) {
            Text("In-app notifications")
              .foregroundColor(.darkGrey)
              .font(.mukta(.regular, size: 13))
            EXDialog(type: .deleteReminders) {
              Button(action: {}, label: {
                Text("Delete all reminders")
                  .font(.mukta(.semibold, size: 15))
              })
              .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
              .padding(.top, 15)
            }
          }
        }
        .padding(.top, 20)
      }
      .scrollDisabled(true)
      .applyMargins()
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
      }
    }
  }
}

struct RemindersSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    RemindersSettingsView()
  }
}

// MARK: - Appearance
extension RemindersSettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Reminders"
    
    let backIcon = Source.Images.Navigation.back
  }
}
