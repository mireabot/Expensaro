//
//  TabBarView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import SwiftUIIntrospect
import ExpensaroUIKit
import Dependencies

struct TabBarView: View {
  @State private var router: Router
  @StateObject private var quickActions = HomeQuickActionsCoordinator()

  init() {
    @Dependency(\.router) var shared
    _router = State(initialValue: shared)
  }

  var body: some View {
    Group {
      if #available(iOS 26.0, *) {
        liquidGlassTabView()
      } else {
        legacyTabView()
      }
    }
    .tint(.primaryGreen)
    .withSheetDestinations(router.sheetBinding)
    .withFullScreenCoverDestinations(router.fullScreenCoverBinding)
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
    case root(RouterTab)
    /// Side button. Never becomes the selection, it opens the quick actions menu instead
    case quickAdd
  }
}

// MARK: - Helper Views
extension TabBarView {
  /// Side button on the trailing edge (search role), bar minimizes on scroll,
  /// add menu morphs out of the side button
  @available(iOS 26.0, *)
  func liquidGlassTabView() -> some View {
    TabView(selection: tabSelection) {
      Tab("Home", image: Source.Images.Tabs.home, value: TabBarTab.root(.home)) {
        HomeRootView()
          .environmentObject(quickActions)
      }
      Tab("Goals", image: Source.Images.Tabs.goals, value: TabBarTab.root(.goals)) {
        GoalsRootView()
      }
      Tab("Overview", image: Source.Images.Tabs.overview, value: TabBarTab.root(.overview)) {
        OverviewRootView()
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
    TabView(selection: tabSelection) {
      HomeRootView()
        .environmentObject(quickActions)
        .tabItem {
          Label("Home", image: Source.Images.Tabs.home)
        }
        .tag(TabBarTab.root(.home))
      GoalsRootView()
        .tabItem {
          Label("Goals", image: Source.Images.Tabs.goals)
        }
        .tag(TabBarTab.root(.goals))
      OverviewRootView()
        .tabItem {
          Label("Overview", image: Source.Images.Tabs.overview)
        }
        .tag(TabBarTab.root(.overview))
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
    router.selectedRootTab == .home && quickActions.isAvailable
  }

  /// Tapping the side button toggles the menu and keeps the current tab selected;
  /// re-tapping the selected tab pops it to its root
  var tabSelection: Binding<TabBarTab> {
    Binding {
      .root(router.selectedRootTab)
    } set: { newValue in
      switch newValue {
      case .quickAdd:
        quickActions.isMenuExpanded.toggle()
      case let .root(tab) where tab == router.selectedRootTab:
        router.tabBarActions()
      case let .root(tab):
        router.selectedRootTab = tab
      }
    }
  }
}
