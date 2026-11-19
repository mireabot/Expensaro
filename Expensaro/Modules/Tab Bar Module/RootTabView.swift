//
//  RootTabView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import SwiftData
import Dependencies

/// The app shell, after phia-swift's root: a page container with the system tab bar hidden, and
/// `RootTabBar` plus the accessory button floating over it. The bar's structure never depends on the
/// pushed screen, so pushes and pops stay native; only the accessory's content and opacity follow it.
struct RootTabView: View {
  @State private var router: Router
  @State private var isAccessoryExpanded = false
  @State private var bottomSafeArea: CGFloat = 0

  // MARK: Accessory input
  @AppStorage("currencySign") private var currencySign = "USD"
  @Query(Budget.thisMonth) private var budget: [Budget]
  @Query(Transaction.thisMonth) private var transactions: [Transaction]
  @Query(DailyTransaction.byDateCreated) private var dailyTransactions: [DailyTransaction]

  init() {
    @Dependency(\.router) var shared
    _router = State(initialValue: shared)
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      pages
      scrim
      bar
    }
    .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { bottomSafeArea = $0 }
    .tint(.primaryGreen)
    .withRouterAlerts(router.alertBinding)
    .withSheetDestinations(router.sheetBinding)
    .withFullScreenCoverDestinations(router.fullScreenCoverBinding)
    .onChange(of: router.selectedRootTab) { isAccessoryExpanded = false }
    .onChange(of: router.currentDestination) { isAccessoryExpanded = false }
    .onChange(of: accessory.isEmpty) { _, isEmpty in
      if isEmpty { isAccessoryExpanded = false }
    }
    .onAppear {
      // iOS 26 navigation bars are Liquid Glass with scroll edge effects;
      // an opaque custom appearance would disable them
      guard #unavailable(iOS 26.0) else { return }

      let navigationBarAppearance = UINavigationBarAppearance()
      navigationBarAppearance.backgroundColor = .white
      navigationBarAppearance.shadowColor = .clear
      UINavigationBar.appearance().standardAppearance = navigationBarAppearance
      UINavigationBar.appearance().compactAppearance = navigationBarAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
  }
}

#Preview {
  RootTabView()
}

// MARK: - Appearance
extension RootTabView {
  struct Appearance {
    static let shared = Appearance()

    let horizontalPadding: CGFloat = 20
    /// From the screen's bottom edge, clear of the home indicator
    let bottomPadding: CGFloat = 24
    let spacing: CGFloat = 10
    /// Between the end of scrolled content and the top of the bar
    let contentGap: CGFloat = 8
  }
}

// MARK: - Helper Views
private extension RootTabView {
  /// Each tab's root keeps its `NavigationStack` alive across switches. The bottom inset is only extra
  /// safe area, so it reaches every pushed screen without the bar knowing about any of them.
  var pages: some View {
    TabView(selection: $router.selectedRootTab) {
      ForEach(RouterTab.allCases) { tab in
        LazyTabPage(tab: tab, isSelected: router.selectedRootTab == tab)
          .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
              .frame(height: barClearance)
          }
          .tag(tab)
          .toolbar(.hidden, for: .tabBar)
          .toolbarVisibility(.hidden, for: .tabBar)
      }
    }
  }

  /// Tap-anywhere dismissal for the open accessory panel
  @ViewBuilder
  var scrim: some View {
    if isAccessoryExpanded {
      Color.black.opacity(0.001)
        .ignoresSafeArea()
        .contentShape(.rect)
        .onTapGesture {
          isAccessoryExpanded = false
        }
    }
  }

  /// Fixed layout: the accessory keeps its slot when it has nothing to offer and only fades
  var bar: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 0)
      HStack(alignment: .bottom, spacing: Appearance.shared.spacing) {
        RootTabBar(tabs: RouterTab.allCases, selection: $router.selectedRootTab) {
          router.tabBarActions()
        }

        TabAccessoryMenu(content: accessory, isExpanded: $isAccessoryExpanded)
      }
    }
    .padding(.horizontal, Appearance.shared.horizontalPadding)
    .padding(.bottom, Appearance.shared.bottomPadding)
    .ignoresSafeArea(.container, edges: .bottom)
    .ignoresSafeArea(.keyboard)
    .animation(.smooth(duration: 0.25), value: isAccessoryExpanded)
  }
}

// MARK: - Helper Functions
private extension RootTabView {
  /// What the accessory offers for the screen on top of the selected tab; empty fades it out
  var accessory: AccessoryContent {
    AccessoryContent.make(tab: router.selectedRootTab,
                          destination: router.currentDestination,
                          router: router,
                          budget: budget.first,
                          transactions: transactions,
                          dailyTransactions: dailyTransactions,
                          currencySign: currencySign)
  }

  /// The bar is placed from the screen edge, the pages' safe area from the device's; this is the
  /// difference. With the keyboard up the device inset is larger than the bar and only the gap remains.
  var barClearance: CGFloat {
    let barTop = RootTabBar.Appearance.shared.height + Appearance.shared.bottomPadding
    return max(barTop - bottomSafeArea, 0) + Appearance.shared.contentGap
  }
}

// MARK: - Lazy page
/// Builds a tab's root the first time it is selected, as phia-swift's `LazyTabView` does,
/// then keeps it so its navigation state survives switching away
private struct LazyTabPage: View {
  let tab: RouterTab
  let isSelected: Bool

  @State private var hasBeenSelected = false

  var body: some View {
    Group {
      if hasBeenSelected {
        tab.makeContentView()
      } else {
        Color.clear
      }
    }
    .onAppear {
      if isSelected { hasBeenSelected = true }
    }
    .onChange(of: isSelected) { _, isSelected in
      if isSelected { hasBeenSelected = true }
    }
  }
}
