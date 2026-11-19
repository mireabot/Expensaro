//
//  WithAppRouter.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI
import Dependencies

extension View {
  /// Registers every pushed `RouterDestination` on the enclosing `NavigationStack`.
  /// Screens draw their own back button, so the system one is hidden.
  func withAppRouter() -> some View {
    navigationDestination(for: RouterDestination.self) { destination in
      RouterWrapper(destination: destination)
        .navigationBarBackButtonHidden()
    }
  }
}

private struct RouterWrapper: View {
  @Dependency(\.router) private var router
  let destination: RouterDestination

  var body: some View {
    screen
      .onDisappear { router.didRemove(destination) }
  }

  /// A screen whose model was deleted renders nothing: it can still be mounted for the rest of a pop
  @ViewBuilder
  private var screen: some View {
    switch destination {
    case .settings:
      SettingsView()
    case .transactionsList:
      TransactionsListView()
    case let .transactionDetail(transaction, budget):
      if transaction.isLive, budget.isLive {
        TransactionDetailView(transaction: transaction, budget: budget)
      }
    case let .recurringPaymentsList(budget):
      if budget.isLive {
        RecurrentPaymentsListView(budget: budget)
      }
    case let .recurringPaymentDetail(payment, budget):
      if payment.isLive, budget.isLive {
        RecurrentPaymentDetailView(transaction: payment, budget: budget)
      }
    case let .goalDetail(goal):
      if goal.isLive {
        GoalDetailView(goal: goal)
      }
    case let .topCategoryOverview(summary):
      TopCategoryOverviewView(summary: summary)
    case let .monthRecap(recap):
      MonthRecapOverviewView(recap: recap)
    case .appSettings:
      AppSettingsView()
    case .currencySelector:
      CurrencySelectorView()
    case .categoriesSettings:
      CategoriesSettingsView()
    case .addCategory:
      DraftModel(Category()) { AddCategoryView(isSheet: false, category: $0) }
    case .remindersSettings:
      RemindersSettingsView()
    case .eraseData:
      EraseDataSettingsView()
    case .contact:
      ContactSettingsView(topic: "General", isCalled: false)
    case .debugMenu:
      DebugMenuView()
    }
  }
}

// MARK: - Swipe back
/// `NavigationStack` is still a `UINavigationController` underneath. Hiding the back button
/// disables its edge-swipe pop, so the gesture is re-enabled for every stack deeper than its root.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    viewControllers.count > 1
  }

  /// Lets the pop gesture start over scroll views
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    true
  }
}
