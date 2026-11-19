//
//  Router.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI

/// App-wide navigation state: one push path per tab plus a single sheet, full-screen cover and alert slot.
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
  private(set) var presentedSheet: RouterSheet?
  private(set) var presentedFullScreenCover: RouterCover?
  private(set) var presentedAlert: RouterAlert?

  /// Work queued by `back(thenPerform:)`, keyed by the screen it waits on
  @ObservationIgnored private var afterPop: [RouterDestination: @MainActor () -> Void] = [:]

  /// Nonisolated so the dependency key can create the shared instance from a static initializer
  nonisolated init() {}

  var isOnRootTab: Bool {
    selectedPath.isEmpty
  }

  /// Top of the selected tab's stack, nil at its root
  var currentDestination: RouterDestination? {
    selectedPath.last
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

  /// Pops the top screen and runs `work` once that screen has left the hierarchy, so deleting the model
  /// it shows can't reach a view that is still on screen. `didRemove(_:)` normally fires it when the pop
  /// transition ends; the timer covers a screen that never reports its disappearance.
  func back(thenPerform work: @escaping @MainActor () -> Void) {
    guard let popped = selectedPath.popLast() else {
      work()
      return
    }
    afterPop[popped] = work
    Task { [weak self] in
      try? await Task.sleep(for: .seconds(1))
      self?.didRemove(popped)
    }
  }

  /// Called by a pushed screen when it disappears; a no-op while it is still in a path
  func didRemove(_ destination: RouterDestination) {
    guard !isInAnyPath(destination), let work = afterPop.removeValue(forKey: destination) else { return }
    work()
  }

  // MARK: Sheets and covers
  func presentSheet(_ sheet: RouterSheet) {
    presentedSheet = sheet
  }

  func dismissSheet() {
    presentedSheet = nil
  }

  func presentFullScreenCover(_ cover: RouterCover) {
    presentedFullScreenCover = cover
  }

  func dismissFullScreenCover() {
    presentedFullScreenCover = nil
  }

  // MARK: Alerts
  func presentAlert(_ alert: RouterAlert) {
    presentedAlert = alert
  }

  func dismissAlert() {
    presentedAlert = nil
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
  var sheetBinding: Binding<RouterSheet?> {
    Binding {
      self.presentedSheet
    } set: { newValue in
      if newValue == nil { self.dismissSheet() }
    }
  }

  /// For `.fullScreenCover(item:)`; only accepts the dismissal
  var fullScreenCoverBinding: Binding<RouterCover?> {
    Binding {
      self.presentedFullScreenCover
    } set: { newValue in
      if newValue == nil { self.dismissFullScreenCover() }
    }
  }

  /// For `.popup(item:)`; only accepts the dismissal
  var alertBinding: Binding<RouterAlert?> {
    Binding {
      self.presentedAlert
    } set: { newValue in
      if newValue == nil { self.dismissAlert() }
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
    presentedAlert = nil
    afterPop = [:]
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

  private func isInAnyPath(_ destination: RouterDestination) -> Bool {
    RouterTab.allCases.contains { path(of: $0).contains(destination) }
  }

  private func setPath(_ path: [RouterDestination], of tab: RouterTab) {
    switch tab {
    case .home: homeRootPath = path
    case .goals: goalsRootPath = path
    case .overview: overviewRootPath = path
    }
  }
}
