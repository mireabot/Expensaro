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
  @StateObject private var quickActions = HomeQuickActionsCoordinator()
  @State private var selection: TabBarTab = .home

  var body: some View {
    Group {
      if #available(iOS 26.0, *) {
        liquidGlassTabView()
      } else {
        legacyTabView()
      }
    }
    .tint(.primaryGreen)
    .onAppear() {
      // iOS 26 uses system Liquid Glass bars with scroll edge effects;
      // opaque custom appearances would disable them
      guard #unavailable(iOS 26.0) else { return }

      let appearance = UITabBarAppearance()
      appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
      appearance.backgroundColor = .white
      UITabBar.appearance().standardAppearance = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance

      let navigationBarAppearance = UINavigationBarAppearance()
      navigationBarAppearance.backgroundColor = .white
      navigationBarAppearance.shadowColor = .clear
      UINavigationBar.appearance().standardAppearance = navigationBarAppearance
      UINavigationBar.appearance().compactAppearance = navigationBarAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    TabBarView()
  }
}

// MARK: - Tabs
extension TabBarView {
  enum TabBarTab: Hashable {
    case home
    case goals
    case overview
    /// Side button. Never becomes the selection, it opens the quick actions menu instead
    case quickAdd
  }

  func homeTab() -> some View {
    // Injected on the root view itself: it lives in its own hosting controller, and environment
    // set on the representable isn't there yet when HomeView's body first reads the coordinator
    RootNavigationController(nav: nav.homeModuleNavigationController,
                             rootView: HomeView().environmentObject(quickActions))
      .ignoresSafeArea()
      .environmentObject(router)
      .onAppear {
        router.nav = nav.homeModuleNavigationController
      }
  }

  func goalsTab() -> some View {
    RootNavigationController(nav: nav.goalsModuleNavigationController, rootView: GoalsListView())
      .ignoresSafeArea()
      .environmentObject(router)
      .onAppear {
        router.nav = nav.goalsModuleNavigationController
      }
  }

  func overviewTab() -> some View {
    RootNavigationController(nav: nav.overviewModuleNavigationController, rootView: OverviewView())
      .ignoresSafeArea()
      .environmentObject(router)
      .onAppear {
        router.nav = nav.overviewModuleNavigationController
      }
  }
}

// MARK: - Helper Views
extension TabBarView {
  /// Side button on the trailing edge (search role), bar minimizes on scroll,
  /// add menu morphs out of the side button
  @available(iOS 26.0, *)
  func liquidGlassTabView() -> some View {
    TabView(selection: tabSelection) {
      Tab("Home", image: Source.Images.Tabs.home, value: TabBarTab.home) {
        homeTab()
      }
      Tab("Goals", image: Source.Images.Tabs.goals, value: TabBarTab.goals) {
        goalsTab()
      }
      Tab("Overview", image: Source.Images.Tabs.overview, value: TabBarTab.overview) {
        overviewTab()
      }
      if showsQuickAdd {
        Tab("Add", systemImage: "plus", value: TabBarTab.quickAdd, role: .search) {
          Color.clear
        }
      }
    }
    .tabBarMinimizeBehavior(.onScrollDown)
    .overlay {
      if showsQuickAdd {
        HomeQuickActionsMenu(coordinator: quickActions)
      }
    }
    .onChange(of: showsQuickAdd) { _, isShown in
      if !isShown { quickActions.isMenuExpanded = false }
    }
  }

  func legacyTabView() -> some View {
    TabView {
      homeTab()
        .tabItem {
          Label("Home", image: Source.Images.Tabs.home)
        }
      goalsTab()
        .tabItem {
          Label("Goals", image: Source.Images.Tabs.goals)
        }
      overviewTab()
        .tabItem {
          Label("Overview", image: Source.Images.Tabs.overview)
        }
    }
    .introspect(.tabView, on: .iOS(.v16,.v17), customize: { tabView in
      tabView.tabBar.unselectedItemTintColor = UIColor(.border)
    })
  }
}

// MARK: - Helper Functions
extension TabBarView {
  /// Same visibility rule as the old Home FAB
  var showsQuickAdd: Bool {
    selection == .home && quickActions.isAvailable
  }

  /// Tapping the side button toggles the menu and keeps the current tab selected
  var tabSelection: Binding<TabBarTab> {
    Binding {
      selection
    } set: { newValue in
      if newValue == .quickAdd {
        quickActions.isMenuExpanded.toggle()
      } else {
        selection = newValue
      }
    }
  }
}
