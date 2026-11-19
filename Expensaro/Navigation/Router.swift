//
//  Router.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI

/// App-wide navigation state: one push path per tab plus a single sheet and full-screen cover slot.
/// Shared through `@Dependency(\.router)`. State is read-only from outside: views push and present
/// only through the methods below, and SwiftUI gets bindings that can pop or dismiss but never push.
@Observable
@MainActor
final class Router {
  var selectedRootTab: RouterTab = .home

  // MARK: NavigationStack root paths
  private(set) var homeRootPath: [RouterDestination] = []
  private(set) var goalsRootPath: [RouterDestination] = []
  private(set) var overviewRootPath: [RouterDestination] = []

  // MARK: Presentation
  private(set) var presentedSheet: RouterDestination?
  private(set) var presentedFullScreenCover: RouterDestination?

  /// Nonisolated so the dependency key can create the shared instance from a static initializer
  nonisolated init() {}

  var isOnRootTab: Bool {
    selectedPath.isEmpty
  }

  // MARK: Push navigation
  /// TODO(tracking): pushes will take an `Arrival` built from a tracked tap's `Origin`,
  /// not a bare destination, so every pushed screen knows which tap opened it.
  func navigate(to destination: RouterDestination) {
    selectedPath.append(destination)
  }

  func back() {
    _ = selectedPath.popLast()
  }

  func popToRoot() {
    selectedPath.removeAll()
  }

  // MARK: Sheets and covers
  func presentSheet(for destination: RouterDestination) {
    presentedSheet = destination
  }

  func dismissSheet() {
    presentedSheet = nil
  }

  func presentFullScreenCover(for destination: RouterDestination) {
    presentedFullScreenCover = destination
  }

  func dismissFullScreenCover() {
    presentedFullScreenCover = nil
  }

  // MARK: Bindings
  /// For `NavigationStack(path:)`. The setter accepts pops (swipe back, system back) and ignores
  /// anything else, so pushes can only come through `navigate(to:)`.
  func path(for tab: RouterTab) -> Binding<[RouterDestination]> {
    Binding {
      self.path(of: tab)
    } set: { newValue in
      let current = self.path(of: tab)
      guard newValue.count < current.count, current.starts(with: newValue) else { return }
      self.setPath(newValue, of: tab)
    }
  }

  /// For `.sheet(item:)`; only accepts the dismissal
  var sheetBinding: Binding<RouterDestination?> {
    Binding {
      self.presentedSheet
    } set: { newValue in
      if newValue == nil { self.dismissSheet() }
    }
  }

  /// For `.fullScreenCover(item:)`; only accepts the dismissal
  var fullScreenCoverBinding: Binding<RouterDestination?> {
    Binding {
      self.presentedFullScreenCover
    } set: { newValue in
      if newValue == nil { self.dismissFullScreenCover() }
    }
  }

  // MARK: Tab bar
  /// Re-tapping the selected tab returns it to its root
  func tabBarActions() {
    guard !isOnRootTab else { return }
    popToRoot()
  }

  // MARK: Reset
  /// Called when all data is erased, so the next session starts from clean stacks
  func reset() {
    selectedRootTab = .home
    homeRootPath = []
    goalsRootPath = []
    overviewRootPath = []
    presentedSheet = nil
    presentedFullScreenCover = nil
  }

  private var selectedPath: [RouterDestination] {
    get { path(of: selectedRootTab) }
    set { setPath(newValue, of: selectedRootTab) }
  }

  private func path(of tab: RouterTab) -> [RouterDestination] {
    switch tab {
    case .home: homeRootPath
    case .goals: goalsRootPath
    case .overview: overviewRootPath
    }
  }

  private func setPath(_ path: [RouterDestination], of tab: RouterTab) {
    switch tab {
    case .home: homeRootPath = path
    case .goals: goalsRootPath = path
    case .overview: overviewRootPath = path
    }
  }
}
