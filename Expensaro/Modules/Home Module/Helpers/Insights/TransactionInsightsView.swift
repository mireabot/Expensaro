//
//  TransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/27/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct TransactionInsightsView: View {
  @ObservedObject var viewModel: TransactionInsightsViewModel
  var body: some View {
    Group {
      if viewModel.isLocked {
        EXEmptyStateView(type: .noTransactionInsights)
      } else {
        VStack(alignment: .leading, spacing: 10) {
          VStack(alignment: .leading, spacing: 5) {
            Text("$\(viewModel.totalSpentInCategory.clean)")
              .font(.system(.title3, weight: .semibold))
            Text("You have spent on \(Text(viewModel.selectedCategory).font(.system(.subheadline, weight: .medium)).foregroundColor(.primaryGreen)) this month")
              .font(.system(.subheadline, weight: .medium))
              .foregroundStyle(Color.darkGrey)
          }
          HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 3) {
              Text("Average amount")
                .font(.system(.footnote, weight: .regular))
                .foregroundColor(.darkGrey)
              Text("$\(viewModel.calculateAverageAmountForCategory().clean)")
                .font(.system(.subheadline, weight: .regular))
            }
            VStack(alignment: .leading, spacing: 3) {
              Text("Budget cut")
                .font(.system(.footnote, weight: .regular))
                .foregroundColor(.darkGrey)
              Text("\(viewModel.calculatePercentageSpentOnCategory().clean)%")
                .font(.system(.subheadline, weight: .regular))
            }
          }
        }
        .padding(12)
        .background(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .inset(by: 0.5)
            .stroke(Color.border, lineWidth: 1)
        )
      }
    }
  }
}

class TransactionInsightsViewModel: ObservableObject {
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  @Published var selectedCategory: String = ""
  @Published var monthlyBudget: Double = 0.0
  @Published var totalSpentInCategory: Double = 0.0
  @Published var isLocked = false
  
  init(category: String, budget: Double) {
    self.selectedCategory = category
    self.monthlyBudget = budget
    calculateTotalSpentInCategory()
  }
  
  /// Calculating total amount spent on selected category
  func calculateTotalSpentInCategory() {
    let selectedCategoryTransactions = transactions.filter({$0.categoryName == self.selectedCategory})
    if selectedCategoryTransactions.count <= 5 {
      isLocked = true
    }
    else {
      totalSpentInCategory = selectedCategoryTransactions.reduce(0.0) { $0 + $1.amount }
    }
  }
  
  /// Calculating average amount spent on selected category
  /// - Returns: Average amount
  func calculateAverageAmountForCategory() -> Double {
    let selectedCategoryTransactions = transactions.filter({$0.categoryName == self.selectedCategory })
    if selectedCategoryTransactions.isEmpty {
      return 0.0
    }
    let totalAmount = selectedCategoryTransactions.reduce(0.0) {$0 + $1.amount}
    return totalAmount / Double(selectedCategoryTransactions.count)
  }
  
  /// Calculating percentage from monthly budget
  /// - Returns: Percentage amount
  func calculatePercentageSpentOnCategory() -> Double {
    return (totalSpentInCategory / monthlyBudget) * 100
  }
}
