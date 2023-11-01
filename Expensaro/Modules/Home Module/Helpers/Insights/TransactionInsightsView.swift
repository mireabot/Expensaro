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
      if viewModel.totalSpentInCategory == 0 {
        emptyState()
      } else {
        VStack(alignment: .leading, spacing: 10) {
          VStack(alignment: .leading, spacing: -5) {
            Text("$\(viewModel.totalSpentInCategory.clean)")
              .font(.mukta(.semibold, size: 20))
            Text("You have spent on \(Text(viewModel.selectedCategory).font(.mukta(.medium, size: 15)).foregroundColor(.primaryGreen)) this month")
              .font(.mukta(.medium, size: 15))
              .foregroundStyle(Color.darkGrey)
          }
          HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: -3) {
              Text("Average amount")
                .font(.mukta(.regular, size: 13))
                .foregroundColor(.darkGrey)
              Text("$\(viewModel.calculateAverageAmountForCategory(), specifier: "%.2f")")
                .font(.mukta(.regular, size: 15))
            }
            VStack(alignment: .leading, spacing: -3) {
              Text("Budget cut")
                .font(.mukta(.regular, size: 13))
                .foregroundColor(.darkGrey)
              Text("\(viewModel.calculatePercentageSpentOnCategory(), specifier: "%.2f")%")
                .font(.mukta(.regular, size: 15))
            }
          }
        }
        .padding(12)
        .background(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.5)
            .stroke(Color.border, lineWidth: 1)
        )
      }
    }
  }
  
  @ViewBuilder
  func emptyState() -> some View {
    VStack(alignment: .center, spacing: 3) {
      Text("There's nothing to show right now")
        .font(.mukta(.semibold, size: 15))
        .multilineTextAlignment(.center)
      Text("We don't have enough data to make insights")
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}

class TransactionInsightsViewModel: ObservableObject {
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  @Published var selectedCategory: String = ""
  @Published var monthlyBudget: Double = 0.0
  @Published var totalSpentInCategory: Double = 0.0
  
  init(category: String, budget: Double) {
    self.selectedCategory = category
    self.monthlyBudget = budget
    calculateTotalSpentInCategory()
  }
  
  /// Calculating total amount spent on selected category
  func calculateTotalSpentInCategory() {
    let selectedCategoryTransactions = transactions.filter({$0.categoryName == self.selectedCategory})
    totalSpentInCategory = selectedCategoryTransactions.reduce(0.0) { $0 + $1.amount }
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
