//
//  ContentView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/9/23.
//

import SwiftUI
import ExpensaroUIKit

struct ContentView: View {
  let nav = NavigationControllers()
  let router = EXNavigationViewsRouter()
  var body: some View {
    TabView {
      RootNavigationController(nav: nav.homeModuleNavigationController, rootView: HomeView())
        .tabItem {
          Label("Home", image: "home")
        }
        .environmentObject(router)
        .onAppear {
          router.nav = nav.homeModuleNavigationController
        }
      RootNavigationController(nav: nav.goalsModuleNavigationController, rootView: GoalsListView())
        .tabItem {
          Label("Goals", image: "goals")
        }
        .environmentObject(router)
        .onAppear {
          router.nav = nav.goalsModuleNavigationController
        }
      RootNavigationController(nav: nav.overviewModuleNavigationController, rootView: Text("Overview"))
        .tabItem {
          Label("Overview", image: "overview")
        }
        .environmentObject(router)
        .onAppear {
          router.nav = nav.overviewModuleNavigationController
        }
    }
    .accentColor(Color(uiColor: UIColor(red: 0.169, green: 0.38, blue: 0.451, alpha: 1.00)))
    .onAppear() {
      if #available(iOS 13.0, *) {
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = tabBarAppearance
        
        if #available(iOS 15.0, *) {
          let navigationBarAppearance = UINavigationBarAppearance()
          navigationBarAppearance.backgroundColor = .white
          navigationBarAppearance.shadowColor = .clear
          UINavigationBar.appearance().standardAppearance = navigationBarAppearance
          UINavigationBar.appearance().compactAppearance = navigationBarAppearance
          UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
          UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
