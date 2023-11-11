//
//  ExpensaroApp.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/9/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

@main
struct ExpensaroApp: SwiftUI.App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.realmConfiguration, RealmMigrator.configuration)
    }
  }
}

struct ContentView: View {
  @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
  var body: some View {
    if isUserLoggedIn {
      TabBarView()
    }
    else {
      OnboardingView()
    }
  }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    MuktaFont.registerFonts()
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    if let aps = userInfo["aps"] as? [String: Any], let badgeCount = aps["badge"] as? Int {
      // Set the badge count on the app icon
      application.applicationIconBadgeNumber = badgeCount
    }
    
    return UIBackgroundFetchResult.noData
  }
  
}
