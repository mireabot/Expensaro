//
//  RouterDestination.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation

/// Screens the router pushes onto a tab's `NavigationStack`, one case per screen carrying only that
/// screen's input. Rendered by `withAppRouter()`. Presented screens are `RouterCover` and `RouterSheet`,
/// so a modal can't be pushed and a pushed screen can't be presented.
enum RouterDestination: Hashable {
  // MARK: Home
  case settings
  case transactionsList
  case transactionDetail(Transaction, Budget)
  case recurringPaymentsList(Budget)
  case recurringPaymentDetail(RecurringTransaction, Budget)

  // MARK: Goals
  case goalDetail(Goal)

  // MARK: Overview
  case topCategoryOverview(TopCategorySummary)
  case monthRecap(MonthRecap)

  // MARK: Settings
  case appSettings
  case currencySelector
  case categoriesSettings
  case addCategory
  case remindersSettings
  case eraseData
  case contact
  case debugMenu
}

// MARK: - Identity
/// Models are compared by reference, never through their SwiftData-backed `persistentModelID`: the path,
/// `starts(with:)` and `Router.afterPop` keep comparing a destination after its model is deleted.
extension RouterDestination {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.identity == rhs.identity
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identity)
  }

  private var identity: [AnyHashable] {
    switch self {
    case .settings: ["settings"]
    case .transactionsList: ["transactionsList"]
    case let .transactionDetail(transaction, budget): ["transactionDetail", ObjectIdentifier(transaction), ObjectIdentifier(budget)]
    case let .recurringPaymentsList(budget): ["recurringPaymentsList", ObjectIdentifier(budget)]
    case let .recurringPaymentDetail(payment, budget): ["recurringPaymentDetail", ObjectIdentifier(payment), ObjectIdentifier(budget)]
    case let .goalDetail(goal): ["goalDetail", ObjectIdentifier(goal)]
    case let .topCategoryOverview(summary): ["topCategoryOverview", summary]
    case let .monthRecap(recap): ["monthRecap", recap]
    case .appSettings: ["appSettings"]
    case .currencySelector: ["currencySelector"]
    case .categoriesSettings: ["categoriesSettings"]
    case .addCategory: ["addCategory"]
    case .remindersSettings: ["remindersSettings"]
    case .eraseData: ["eraseData"]
    case .contact: ["contact"]
    case .debugMenu: ["debugMenu"]
    }
  }
}
