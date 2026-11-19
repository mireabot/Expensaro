//
//  RouterAlert.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation

/// Confirmations the router presents over every tab, one case per alert carrying only its input.
/// Rendered once by `withRouterAlerts()`, see WithRouterAlerts.swift.
enum RouterAlert: Hashable, Identifiable {
  case deleteTransaction(Transaction, Budget)
  case deleteRecurringPayment(RecurringTransaction, Budget)
  case deleteGoal(Goal)

  var id: Self {
    self
  }

  var type: Source.Strings.AlertType {
    switch self {
    case .deleteTransaction: .deleteTransaction
    case .deleteRecurringPayment: .deletePayment
    case .deleteGoal: .deleteGoal
    }
  }
}

// MARK: - Identity
/// By reference, like `RouterDestination`: the popup compares the alert while its model is being deleted
extension RouterAlert {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.identity == rhs.identity
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identity)
  }

  private var identity: [AnyHashable] {
    switch self {
    case let .deleteTransaction(transaction, budget): ["deleteTransaction", ObjectIdentifier(transaction), ObjectIdentifier(budget)]
    case let .deleteRecurringPayment(payment, budget): ["deleteRecurringPayment", ObjectIdentifier(payment), ObjectIdentifier(budget)]
    case let .deleteGoal(goal): ["deleteGoal", ObjectIdentifier(goal)]
    }
  }
}
