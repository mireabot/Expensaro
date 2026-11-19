//
//  WithSheetDestinations.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI
import SwiftData

extension View {
  func withSheetDestinations(_ destination: Binding<RouterDestination?>) -> some View {
    sheet(item: destination) { destination in
      SheetDestinationView(destination: destination)
    }
  }

  func withFullScreenCoverDestinations(_ destination: Binding<RouterDestination?>) -> some View {
    fullScreenCover(item: destination) { destination in
      FullScreenCoverDestinationView(destination: destination)
    }
  }
}

private struct SheetDestinationView: View {
  let destination: RouterDestination

  var body: some View {
    switch destination {
    case .featuresHub:
      WishView()
    default:
      EmptyView()
    }
  }
}

/// Add and edit flows own their `NavigationStack` and close with `dismiss`,
/// which clears the router's cover through `Router.fullScreenCoverBinding`.
/// `.contact` is pushed from Settings and presented as a cover for in-context feedback.
private struct FullScreenCoverDestinationView: View {
  let destination: RouterDestination

  var body: some View {
    switch destination {
    case .addBudget:
      DraftModel(Budget()) { AddBudgetView(type: .addBudget, budget: $0) }
    case let .updateBudget(budget):
      AddBudgetView(type: .updateBudget, budget: budget)
    case let .addTransaction(budget):
      DraftModel(Transaction()) { AddTransactionView(transaction: $0, budget: budget) }
    case let .editTransaction(transaction, budget):
      AddTransactionView(transaction: transaction, budget: budget)
    case let .addRecurringPayment(budget):
      DraftModel(RecurringTransaction()) { AddRecurrentPaymentView(recurringPayment: $0, budget: budget) }
    case let .editRecurringPayment(payment, budget):
      AddRecurrentPaymentView(recurringPayment: payment, budget: budget)
    case .dailyTransactions:
      DailyTransactionsListView()
    case .addGoal:
      DraftModel(Goal()) { AddGoalView(goal: $0) }
    case let .editGoal(goal):
      EditGoalView(goal: goal)
    case let .addGoalMoney(goal):
      DraftModel(GoalTransaction()) { AddGoalTransactionView(goalTransaction: $0, goal: goal) }
    case let .contact(topic):
      NavigationStack {
        ContactSettingsView(topic: topic, isCalled: true)
      }
    default:
      EmptyView()
    }
  }
}

/// Holds an unsaved model for the lifetime of a create flow.
/// Destination builders re-run whenever their host re-renders; creating the model inline would
/// hand the form a blank instance mid-edit.
struct DraftModel<Model: PersistentModel, Content: View>: View {
  @State private var model: Model
  private let content: (Model) -> Content

  init(_ model: @autoclosure () -> Model, @ViewBuilder content: @escaping (Model) -> Content) {
    _model = State(initialValue: model())
    self.content = content
  }

  var body: some View {
    content(model)
  }
}
