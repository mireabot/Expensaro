//
//  RouterTab.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI

/// Root tabs, each with its own navigation path in `Router`.
/// The accessory button beside the tab bar is a shell concern and is not a tab here.
enum RouterTab: Int, CaseIterable, Hashable, Identifiable {
  case home
  case goals
  case overview

  var id: Int {
    rawValue
  }
}

// MARK: - Content
extension RouterTab {
  /// The tab's root, which owns its `NavigationStack`
  @MainActor
  @ViewBuilder
  func makeContentView() -> some View {
    switch self {
    case .home: HomeRootView()
    case .goals: GoalsRootView()
    case .overview: OverviewRootView()
    }
  }

  /// Asset name, drawn as a template so the bar can tint it
  var icon: String {
    switch self {
    case .home: Source.Images.Tabs.home
    case .goals: Source.Images.Tabs.goals
    case .overview: Source.Images.Tabs.overview
    }
  }

  var label: String {
    switch self {
    case .home: "Home"
    case .goals: "Goals"
    case .overview: "Overview"
    }
  }
}
