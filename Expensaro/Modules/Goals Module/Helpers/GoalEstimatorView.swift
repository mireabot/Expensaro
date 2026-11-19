//
//  GoalEstimatorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/18/24.
//

import SwiftUI
import ExpensaroUIKit
import Shimmer

struct GoalEstimatorView: View {
  /// Month's initial budget, goal amount, days left
  var goalInfo: (Double, Double, Int)
  @State private var isCalculated = false
  @State private var isLoading = false
  
  private var estimate: GoalSuccessEstimate {
    GoalSuccessEstimate(monthlyExpensesBudget: goalInfo.0, goalAmount: goalInfo.1, daysToGoal: goalInfo.2)
  }
  
  var body: some View {
    VStack {
      if !isCalculated || estimate.successRate == 0 {
        emptyState()
      } else if isLoading {
        EXBaseCard {
          VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 0, content: {
              VStack(alignment: .leading, spacing: 3) {
                Text("Goal success rate")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                Text("\(estimate.successRate.clean)%")
                  .font(.title2Bold)
                  .redacted(reason: .placeholder)
                  .shimmering(active: isLoading)
              }
              Spacer()
            })
            Divider()
            VStack(alignment: .leading, spacing: 3, content: {
              Text(estimate.rateInformation.title)
                .font(.headlineBold)
                .foregroundColor(estimate.rateInformation.color)
                .redacted(reason: .placeholder)
                .shimmering(active: isLoading)
              Text(estimate.rateInformation.text)
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
                .redacted(reason: .placeholder)
                .shimmering(active: isLoading)
            })
          }
          .frame(maxWidth: .infinity)
        }
      } else {
        EXBaseCard {
          VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 0, content: {
              VStack(alignment: .leading, spacing: 3) {
                Text("Goal success rate")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                Text("\(estimate.successRate.clean)%")
                  .font(.title2Bold)
              }
              Spacer()
            })
            Divider()
            VStack(alignment: .leading, spacing: 3, content: {
              Text(estimate.rateInformation.title)
                .font(.headlineBold)
                .foregroundColor(estimate.rateInformation.color)
              Text(estimate.rateInformation.text)
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            })
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
    .task(id: isLoading) {
      guard isLoading else { return }
      try? await Task.sleep(for: .seconds(1))
      isLoading = false
    }
  }
}

#Preview {
  GoalEstimatorView(goalInfo: (1500, 780, 34))
    .applyMargins()
}

extension GoalEstimatorView {
  @ViewBuilder
  func emptyState() -> some View {
    EXBaseCard {
      VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading, spacing: 3, content: {
          Source.Images.System.smartWidget
          Text("Check goal success rate")
            .font(.headlineBold)
          Text("Estimate the probability of achieving your financial goal on time")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
        })
        Button(action: {
          isCalculated = true
          withAnimation(.interactiveSpring) {
            isLoading = true
          }
        }, label: {
          Text("Calculate")
            .font(.subheadlineSemibold)
            .frame(maxWidth: .infinity, alignment: .center)
        })
        .tint(.primaryGreen)
        .buttonStyle(.borderedProminent)
      }
    }
  }
}
