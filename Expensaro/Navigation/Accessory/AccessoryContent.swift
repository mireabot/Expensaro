//
//  AccessoryContent.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI
import SwiftData

/// One row of the tab bar accessory. `id` is a stable literal so a later tracking layer can
/// attribute the tap to the current destination; rows built from models (daily transactions)
/// share it and are told apart by `object`, so lists key on `rowID`.
struct AccessoryAction: Identifiable {
  struct RowID: Hashable {
    let id: String
    let object: PersistentIdentifier?
  }

  enum Icon {
    case asset(String)
    case symbol(String)
    case emoji(String)
  }

  let id: String
  var object: PersistentIdentifier? = nil
  let title: String
  let icon: Icon
  var detail: String? = nil
  var role: ButtonRole? = nil
  let perform: @MainActor () -> Void

  var rowID: RowID {
    RowID(id: id, object: object)
  }
}

/// A titled group renders with a header; an untitled one inline
struct AccessorySection: Identifiable {
  let id: String
  var title: String? = nil
  let actions: [AccessoryAction]
}

/// What the tab bar accessory offers for the screen on top of the selected tab
struct AccessoryContent {
  enum Style {
    /// Root-level creation, plus glyph
    case add
    /// Actions on the item on screen, ellipsis glyph on brand green
    case item
  }

  let style: Style
  let sections: [AccessorySection]

  static let hidden = AccessoryContent(style: .add, sections: [])

  var isEmpty: Bool {
    sections.allSatisfy(\.actions.isEmpty)
  }
}

// MARK: - Mapping
extension AccessoryContent {
  /// The morph panel can't scroll, so only the first few daily transactions get a quick row
  static let maxDailyRows = 4

  @MainActor
  static func make(tab: RouterTab,
                   destination: RouterDestination?,
                   router: Router,
                   budget: Budget?,
                   transactions: [Transaction],
                   dailyTransactions: [DailyTransaction],
                   currencySign: String) -> AccessoryContent {
    switch destination {
    case nil:
      switch tab {
      case .home:
        return home(router: router,
                    budget: budget,
                    transactions: transactions,
                    dailyTransactions: dailyTransactions,
                    currencySign: currencySign)
      case .goals, .overview:
        return .hidden
      }
    // A model deleted under the screen gets no actions, and its properties are never read
    case let .transactionDetail(transaction, budget):
      guard transaction.isLive, budget.isLive else { return .hidden }
      return transactionDetail(transaction, budget: budget, router: router)
    case let .recurringPaymentDetail(payment, budget):
      guard payment.isLive, budget.isLive else { return .hidden }
      return recurringPaymentDetail(payment, budget: budget, router: router)
    case let .goalDetail(goal):
      guard goal.isLive else { return .hidden }
      return goalDetail(goal, router: router)
    // Listed one by one so a new screen has to pick its accessory here
    case .settings, .transactionsList, .recurringPaymentsList, .topCategoryOverview, .monthRecap,
         .appSettings, .currencySelector, .categoriesSettings, .addCategory, .remindersSettings,
         .eraseData, .contact, .debugMenu:
      return .hidden
    }
  }

  /// Same rule as Home's old FAB: a budget with money and at least one transaction this month
  @MainActor
  private static func home(router: Router,
                           budget: Budget?,
                           transactions: [Transaction],
                           dailyTransactions: [DailyTransaction],
                           currencySign: String) -> AccessoryContent {
    guard let budget, budget.isLive, budget.amount != 0, !transactions.isEmpty else { return .hidden }

    let daily = dailyTransactions.prefix(maxDailyRows).map { dailyTransaction in
      AccessoryAction(id: "home.daily_transaction",
                      object: dailyTransaction.persistentModelID,
                      title: dailyTransaction.name,
                      icon: .emoji(dailyTransaction.categoryIcon),
                      detail: dailyTransaction.amount.formattedAsCurrency(with: currencySign)) {
        guard (try? dailyTransaction.spend(from: budget)) == true else { return }
        AnalyticsManager.shared.log(.dailyTransactionUsed)
      }
    }
    let manage = AccessoryAction(id: "home.manage_daily_transactions",
                                 title: "Manage daily transactions",
                                 icon: .symbol("plus")) {
      router.presentFullScreenCover(.dailyTransactions)
    }

    return AccessoryContent(style: .add, sections: [
      AccessorySection(id: "home.daily", title: "Daily transactions", actions: daily + [manage]),
      AccessorySection(id: "home.add", actions: [
        AccessoryAction(id: "home.add_transaction", title: "Add transaction", icon: .asset("buttonTransaction")) {
          router.presentFullScreenCover(.addTransaction(budget))
        },
        AccessoryAction(id: "home.add_recurring_payment", title: "Add recurring payment", icon: .asset("buttonRecurrent")) {
          router.presentFullScreenCover(.addRecurringPayment(budget))
        },
      ]),
    ])
  }

  @MainActor
  private static func transactionDetail(_ transaction: Transaction, budget: Budget, router: Router) -> AccessoryContent {
    var actions: [AccessoryAction] = []
    if transaction.type != "Refill" {
      actions.append(AccessoryAction(id: "transaction_detail.edit", title: "Edit transaction", icon: .asset("buttonEdit")) {
        router.presentFullScreenCover(.editTransaction(transaction, budget))
      })
    }
    actions.append(AccessoryAction(id: "transaction_detail.delete", title: "Delete transaction", icon: .asset("buttonDelete"), role: .destructive) {
      router.presentAlert(.deleteTransaction(transaction, budget))
    })
    return AccessoryContent(style: .item, sections: [AccessorySection(id: "transaction_detail", actions: actions)])
  }

  @MainActor
  private static func recurringPaymentDetail(_ payment: RecurringTransaction, budget: Budget, router: Router) -> AccessoryContent {
    AccessoryContent(style: .item, sections: [
      AccessorySection(id: "recurring_payment_detail", actions: [
        AccessoryAction(id: "recurring_payment_detail.edit", title: "Edit payment", icon: .asset("buttonEdit")) {
          router.presentFullScreenCover(.editRecurringPayment(payment, budget))
        },
        AccessoryAction(id: "recurring_payment_detail.delete", title: "Delete payment", icon: .asset("buttonDelete"), role: .destructive) {
          router.presentAlert(.deleteRecurringPayment(payment, budget))
        },
      ]),
    ])
  }

  @MainActor
  private static func goalDetail(_ goal: Goal, router: Router) -> AccessoryContent {
    let delete = AccessoryAction(id: "goal_detail.delete", title: "Delete goal", icon: .asset("buttonDelete"), role: .destructive) {
      router.presentAlert(.deleteGoal(goal))
    }
    let actions: [AccessoryAction] = goal.isCompleted || goal.isFailed
      ? [delete]
      : [
        AccessoryAction(id: "goal_detail.add_money", title: "Add money", icon: .asset("buttonTransaction")) {
          router.presentFullScreenCover(.addGoalMoney(goal))
        },
        AccessoryAction(id: "goal_detail.edit", title: "Edit goal", icon: .asset("buttonEdit")) {
          router.presentFullScreenCover(.editGoal(goal))
        },
        delete,
      ]
    return AccessoryContent(style: .item, sections: [AccessorySection(id: "goal_detail", actions: actions)])
  }
}
