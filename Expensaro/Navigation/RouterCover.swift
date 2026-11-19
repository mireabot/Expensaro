//
//  RouterCover.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation

/// Screens the router presents as a full-screen cover, one case per screen carrying only that
/// screen's input. Rendered by `withFullScreenCoverDestinations(_:)`, see WithSheetDestinations.swift.
enum RouterCover: Hashable, Identifiable {
  // MARK: Budget
  case addBudget
  case updateBudget(Budget)

  // MARK: Transactions
  case addTransaction(Budget)
  case editTransaction(Transaction, Budget)
  case addRecurringPayment(Budget)
  case editRecurringPayment(RecurringTransaction, Budget)
  case dailyTransactions

  // MARK: Goals
  case addGoal
  case editGoal(Goal)
  case addGoalMoney(Goal)

  // MARK: Feedback
  /// In-context feedback; `topic` names the screen it was sent from
  case feedback(topic: String)

  var id: Self {
    self
  }
}
