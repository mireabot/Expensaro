//
//  ExpensaroApp.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/9/23.
//

import SwiftUI
import ExpensaroUIKit

@main
struct ExpensaroApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
  @State private var isLoading = true
  var body: some Scene {
    WindowGroup {
      if isLoading {
        LaunchView()
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
              isLoading = false
            }
          }
      } else {
        if isUserLoggedIn {
          TabBarView()
            .environment(\.managedObjectContext, CategoriesProvider.shared.viewContext)
        }
        else {
          OnboardingView()
        }
      }
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

struct LaunchView: View {
  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 5) {
        Image("launchIcon")
          .resizable()
          .frame(width: 100, height: 100)
          .cornerRadius(20)
        VStack(alignment: .leading, spacing: -5) {
          Text("Expensaro")
            .font(.mukta(.bold, size: 34))
          Text("Plan all budgets")
            .font(.mukta(.semibold, size: 20))
            .foregroundColor(.darkGrey)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .applyMargins()
      .padding(.top, 150)
      
      Spacer()
    }
    .safeAreaInset(edge: .bottom) {
      CircularProgress()
        .padding(.bottom, 20)
    }
  }
}
struct LaunchView_Previews: PreviewProvider {
  static var previews: some View {
    LaunchView()
  }
}

public struct CircularProgress: View {
  @State private var isCircleRotation = true
  @State private var animationStart = true
  @State private var animationEnd = true
  
  public var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 4)
        .fill(Color.white)
        .frame(width: 20, height: 20)
      
      Circle()
        .trim(from: animationStart ? 1/3 : 1/9, to: animationEnd ? 2/5 : 1)
        .stroke(lineWidth: 4)
        .rotationEffect(.degrees(isCircleRotation ? 360 : 0))
        .frame(width: 20, height: 20)
        .foregroundColor(.primaryGreen)
        .onAppear {
          withAnimation(Animation
            .linear(duration: 1)
            .repeatForever(autoreverses: false)) {
              self.isCircleRotation.toggle()
            }
          withAnimation(Animation
            .linear(duration: 1)
            .delay(0.5)
            .repeatForever(autoreverses: true)) {
              self.animationStart.toggle()
            }
          withAnimation(Animation
            .linear(duration: 1)
            .delay(1)
            .repeatForever(autoreverses: true)) {
              self.animationEnd.toggle()
            }
        }
    }
  }
}
