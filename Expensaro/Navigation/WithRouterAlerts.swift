//
//  WithRouterAlerts.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import PopupView

extension View {
  /// Presents `Router.presentedAlert` as the app's `EXAlert` popup
  func withRouterAlerts(_ alert: Binding<RouterAlert?>) -> some View {
    popup(item: alert) { alert in
      RouterAlertView(alert: alert)
    } customize: {
      $0
        .animation(.spring())
        .position(.bottom)
        .type(.floater(useSafeAreaInset: true))
        .closeOnTapOutside(false)
        .backgroundColor(.black.opacity(0.3))
        .isOpaque(true)
    }
  }
}

private struct RouterAlertView: View {
  @Dependency(\.router) private var router
  let alert: RouterAlert

  var body: some View {
    EXAlert<EmptyView>(config: (alert.type.title,
                                alert.type.subTitle,
                                alert.type.secondaryButtonText,
                                alert.type.primaryButtonText),
                       primaryAction: { confirm() },
                       secondaryAction: { router.dismissAlert() })
    .applyMargins()
  }

  /// Every alert deletes the item on screen. The screen is popped first and the delete waits until it has
  /// left the hierarchy: deleting while it, the accessory or the path still read the model traps in SwiftData.
  private func confirm() {
    router.dismissAlert()
    switch alert {
    case let .deleteTransaction(transaction, budget):
      AnalyticsManager.shared.log(.deleteTransaction)
      router.back {
        guard transaction.isLive, budget.isLive else { return }
        try? transaction.delete(restoring: budget)
      }
    case let .deleteRecurringPayment(payment, budget):
      AnalyticsManager.shared.log(.deletePayment)
      router.back {
        guard payment.isLive, budget.isLive else { return }
        // Contributions go with the payment through the cascade delete rule
        try? payment.delete(refunding: budget)
      }
    case let .deleteGoal(goal):
      AnalyticsManager.shared.log(.deleteGoal)
      router.back {
        guard goal.isLive else { return }
        // Goal transactions go with the goal through the cascade delete rule
        try? goal.delete()
      }
    }
  }
}
