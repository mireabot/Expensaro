//
//  InitialPermissionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import UserNotifications

struct InitialPermissionView: View {
  @Environment(\.realm) var realm
  
  @State private var notificationsSelected = false
  @State private var analyticsSelected = false
  @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
  
  @State private var showAnimation = false
  
  let notificationManager: NotificationManager = NotificationManager.shared
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text("Permissions")
          .font(.mukta(.semibold, size: 20))
        Text("Before we start - we need a few things to set up")
          .font(.mukta(.regular, size: 15))
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top)
      
      VStack(spacing: 20) {
        EXToggleCard(type: .notifications, isOn: $notificationsSelected)
          .onChange(of: notificationsSelected, perform: { value in
            if value {
              DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                UserDefaults.standard.setValue(true, forKey: "notificationsEnabled")
                UserDefaults.standard.synchronize()
              }
            } else {
              DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
                UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
                UserDefaults.standard.synchronize()
              }
            }
          })
        EXToggleCard(type: .analytics, isOn: $analyticsSelected)
      }
    }
    .interactiveDismissDisabled(true)
    .safeAreaInset(edge: .bottom, content: {
      Button {
        showAnimation.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          showAnimation.toggle()
          UserDefaults.standard.setValue(UIDevice.current.identifierForVendor?.uuidString, forKey: "DeviceID")
          UserDefaults.standard.synchronize()
          isUserLoggedIn = true
        }
      } label: {
        Text("Finish")
          .font(.mukta(.semibold, size: 17))
      }
      .buttonStyle(EXPrimaryButtonStyle(showLoader: $showAnimation))
      .padding(.bottom, 20)
      
    })
    .applyMargins()
    .scrollDisabled(true)
    .onAppear {
      notificationManager.requestAuthorization {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
          notificationsSelected.toggle()
          UserDefaults.standard.setValue(true, forKey: "notificationsEnabled")
          UserDefaults.standard.synchronize()
        }
      } onFail: {
        UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
        UserDefaults.standard.synchronize()
      }
    }
  }
}

struct InitialPermissionView_Previews: PreviewProvider {
  static var previews: some View {
    InitialPermissionView()
  }
}
