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
          .font(.system(.title3, weight: .semibold))
        Text("Before we start - we need a few things to set up")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 20)
      
      VStack(spacing: 16) {
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
      .padding(.top, 16)
    }
    .interactiveDismissDisabled(true)
    .safeAreaInset(edge: .bottom, content: {
      Button {
        showAnimation.toggle()
        writeCategories()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          showAnimation.toggle()
          UserDefaults.standard.setValue(UIDevice.current.identifierForVendor?.uuidString, forKey: "DeviceID")
          UserDefaults.standard.synchronize()
          isUserLoggedIn = true
        }
      } label: {
        Text("Finish")
          .font(.system(.headline, weight: .semibold))
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
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Realm Functions
extension InitialPermissionView {
  func writeCategories() {
    let loadedCategories: [Category] = [
      Source.Realm.createCategory(icon: "🔄", name: "Subscription", tag: .base, section: .entertainment),
      Source.Realm.createCategory(icon: "🎫", name: "Entertainment", tag: .base, section: .entertainment),
      Source.Realm.createCategory(icon: "🎨", name: "Hobby", tag: .base, section: .entertainment),
      
      Source.Realm.createCategory(icon: "🥡", name: "Going out", tag: .base, section: .food),
      Source.Realm.createCategory(icon: "🛒", name: "Groceries", tag: .base, section: .food),
      
      Source.Realm.createCategory(icon: "🧾", name: "Bills", tag: .base, section: .housing),
      Source.Realm.createCategory(icon: "🏠", name: "Utilities", tag: .base, section: .housing),
      
      Source.Realm.createCategory(icon: "🚈", name: "Public transport", tag: .base, section: .transportation),
      Source.Realm.createCategory(icon: "🚘", name: "Car", tag: .base, section: .transportation),
      
      Source.Realm.createCategory(icon: "📚", name: "Education", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🛩️", name: "Travel", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🛍️", name: "Shopping", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "📦", name: "Delivery", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🎮", name: "Gaming", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🐾", name: "Animals", tag: .base, section: .lifestyle),
      
      Source.Realm.createCategory(icon: "👕", name: "Clothes", tag: .base, section: .other),
      Source.Realm.createCategory(icon: "📔", name: "Other", tag: .base, section: .other),
      Source.Realm.createCategory(icon: "🩹", name: "Healthcare", tag: .base, section: .other),
    ]
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(loadedCategories)
    })
  }
}
