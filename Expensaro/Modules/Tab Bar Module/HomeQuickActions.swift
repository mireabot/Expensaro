//
//  HomeQuickActions.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/26.
//

import SwiftUI

/// Actions offered by the tab bar's add button. Home owns the presentation and storage writes,
/// the tab bar only decides which one was picked
enum HomeQuickAction: Equatable {
  case addTransaction
  case addRecurringPayment
  case manageDailyTransactions
  case addDailyTransaction(DailyTransaction)
}

/// Shared between the tab bar (iOS 26 side button + morph menu) and Home
final class HomeQuickActionsCoordinator: ObservableObject {
  /// Set by Home: a budget and at least one transaction exist, same rule as the old FAB
  @Published var isAvailable = false
  @Published var isMenuExpanded = false
  /// Consumed and reset by Home
  @Published var pendingAction: HomeQuickAction?

  func perform(_ action: HomeQuickAction) {
    isMenuExpanded = false
    pendingAction = action
  }
}
