//
//  TabBarView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import SwiftUIIntrospect
import ExpensaroUIKit

struct TabBarView: View {
  let nav = NavigationControllers()
  let router = EXNavigationViewsRouter()
  var body: some View {
    TabView {
      RootNavigationController(nav: nav.homeModuleNavigationController, rootView: HomeView())
        .tabItem {
          Label("Home", image: Source.Images.Tabs.home)
        }
        .environmentObject(router)
        .onAppear {
          router.nav = nav.homeModuleNavigationController
        }
      RootNavigationController(nav: nav.goalsModuleNavigationController, rootView: GoalsListView())
        .tabItem {
          Label("Goals", image: Source.Images.Tabs.goals)
        }
        .environmentObject(router)
        .onAppear {
          router.nav = nav.goalsModuleNavigationController
        }
      RootNavigationController(nav: nav.overviewModuleNavigationController, rootView: OverviewView())
        .tabItem {
          Label("Overview", image: Source.Images.Tabs.overview)
        }
        .environmentObject(router)
        .onAppear {
          router.nav = nav.overviewModuleNavigationController
        }
    }
    .introspect(.tabView, on: .iOS(.v16,.v17), customize: { tabView in
      tabView.tabBar.unselectedItemTintColor = UIColor(.border)
    })
    .accentColor(.primaryGreen)
    .onAppear() {
      if #available(iOS 15.0, *) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
      }
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    TabBarView()
  }
}
