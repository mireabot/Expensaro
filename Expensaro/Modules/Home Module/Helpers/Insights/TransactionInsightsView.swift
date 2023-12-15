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
        EXEmptyStateView(type: .noTransactionInsights, isActive: true)
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
          RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.5)
            .stroke(Color.border, lineWidth: 1)
        )
      }
    }
  }
}

struct TransactionInsightsViewNew: View {
  var body: some View {
    Group {
      EXBaseCard {
        VStack(alignment: .leading) {
          HStack {
            VStack(alignment: .leading, spacing: 0) {
              Text("$109.68")
                .font(.title3Bold)
                .foregroundColor(.black)
              Text("Avg. transaction amount")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            }
            
            Spacer()
            
            Source.Images.InfoCardIcon.month2month
              .foregroundColor(.primaryGreen)
          }
          VStack(alignment: .leading, spacing: 5) {
            Text("Top 3 transactions in category")
              .font(.footnoteMedium)
              .foregroundColor(.black)
            VStack(spacing: 10) {
              HStack(alignment: .center) {
                Text("Nike shoes")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                  
                Spacer()
                
                Text("$118.50")
                  .font(.footnoteMedium)
                  .foregroundColor(.primaryGreen)
              }
              HStack(alignment: .center) {
                Text("Electronics purchase")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                  
                Spacer()
                
                Text("$68.09")
                  .font(.footnoteMedium)
                  .foregroundColor(.primaryGreen)
              }
              HStack(alignment: .center) {
                Text("Books")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                  
                Spacer()
                
                Text("$54.49")
                  .font(.footnoteMedium)
                  .foregroundColor(.primaryGreen)
              }
            }
            .padding(.top, 3)
          }
          .padding(10)
          .background(.white)
          .cornerRadius(8)
          .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

#Preview {
  TransactionInsightsViewNew().applyMargins()
}

class TransactionInsightsViewModel: ObservableObject {
  // Transactions to analize
  @ObservedResults(Transaction.self, filter: NSPredicate(format: "date >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var transactions
  
  // Current budget
  @ObservedResults(Budget.self, filter: NSPredicate(format: "dateCreated >= %@", Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))! as CVarArg)) var budget
  
  // Inputs
  @Published var selectedCategory: String = ""
  
  // Displaying variables
  @Published var totalSpentInCategory: Double = 0.0
  
  // Helpers
  @Published var isLocked = false
  
  init(category: String) {
    self.selectedCategory = category
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
    return (totalSpentInCategory / (budget.first?.amount ?? 0)) * 100
  }
}
