//
//  WithSheetDestinations.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI
import SwiftData

extension View {
  func withSheetDestinations(_ sheet: Binding<RouterSheet?>) -> some View {
    self.sheet(item: sheet) { sheet in
      SheetDestinationView(sheet: sheet)
    }
  }

  func withFullScreenCoverDestinations(_ cover: Binding<RouterCover?>) -> some View {
    fullScreenCover(item: cover) { cover in
      FullScreenCoverDestinationView(cover: cover)
    }
  }
}

private struct SheetDestinationView: View {
  let sheet: RouterSheet

  var body: some View {
    switch sheet {
    case .featuresHub:
      WishView()
    }
  }
}

/// Add and edit flows own their `NavigationStack` and close with `dismiss`,
/// which clears the router's cover through `Router.fullScreenCoverBinding`.
/// `.feedback` is the cover counterpart of the pushed `RouterDestination.contact`.
private struct FullScreenCoverDestinationView: View {
  let cover: RouterCover

  var body: some View {
    switch cover {
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
    case let .feedback(topic):
      NavigationStack {
        ContactSettingsView(topic: topic, isCalled: true)
      }
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
