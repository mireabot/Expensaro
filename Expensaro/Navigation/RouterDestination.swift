//
//  RouterDestination.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation

/// Every screen the router pushes or presents, one case per screen carrying only that screen's input.
/// Pushed cases render in `withAppRouter()`, presented ones in `WithSheetDestinations.swift`.
enum RouterDestination: Hashable, Identifiable {
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
  case contact(topic: String)
  case debugMenu

  // MARK: Full-screen covers
  case addBudget
  case updateBudget(Budget)
  case addTransaction(Budget)
  case editTransaction(Transaction, Budget)
  case addRecurringPayment(Budget)
  case editRecurringPayment(RecurringTransaction, Budget)
  case dailyTransactions
  case addGoal
  case editGoal(Goal)
  case addGoalMoney(Goal)

  // MARK: Sheets
  case featuresHub

  var id: Self {
    self
  }
}
