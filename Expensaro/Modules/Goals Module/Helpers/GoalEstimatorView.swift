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
  @ObservedObject var goalManager : GoalManager
  var goalInfo: (Double, Double, Int)
  var body: some View {
    VStack {
      if goalManager.successRate == 0 {
        emptyState()
      } else if goalManager.isLoading {
        EXBaseCard {
          VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 0, content: {
              VStack(alignment: .leading, spacing: 3) {
                Text("Goal success rate")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                Text("\(goalManager.successRate.clean)%")
                  .font(.title2Bold)
                  .redacted(reason: .placeholder)
                  .shimmering(active: goalManager.isLoading)
              }
              Spacer()
            })
            Divider()
            VStack(alignment: .leading, spacing: 3, content: {
              Text(goalManager.rateInformation.title)
                .font(.headlineBold)
                .foregroundColor(goalManager.rateInformation.color)
                .redacted(reason: .placeholder)
                .shimmering(active: goalManager.isLoading)
              Text(goalManager.rateInformation.text)
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
                .redacted(reason: .placeholder)
                .shimmering(active: goalManager.isLoading)
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
                Text("\(goalManager.successRate.clean)%")
                  .font(.title2Bold)
              }
              Spacer()
            })
            Divider()
            VStack(alignment: .leading, spacing: 3, content: {
              Text(goalManager.rateInformation.title)
                .font(.headlineBold)
                .foregroundColor(goalManager.rateInformation.color)
              Text(goalManager.rateInformation.text)
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            })
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
  }
}

#Preview {
  GoalEstimatorView(goalManager: .init(), goalInfo: (1500, 780, 34))
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
          goalManager.calculateSuccessRate(monthlyExpensesBudget: goalInfo.0, goalAmount: goalInfo.1, daysToGoal: goalInfo.2)
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
