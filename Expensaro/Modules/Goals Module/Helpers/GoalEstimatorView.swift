//
//  GoalEstimatorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/18/24.
//

import SwiftUI
import ExpensaroUIKit

struct GoalEstimatorView: View {
  @StateObject var goalManager = GoalMathManager.shared
  var body: some View {
    EXBaseCard {
      VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading, spacing: 3) {
          Text("57%")
            .font(.title3Bold)
          Text("You have good chances to make this goal")
            .font(.calloutRegular)
            .foregroundColor(.darkGrey)
        }
        HStack {
          Rectangle()
            .fill(.green)
            .frame(height: 20)
            .cornerRadius(5)
          Rectangle()
            .fill(.yellow)
            .frame(height: 20)
            .cornerRadius(5)
          Rectangle()
            .fill(.red)
            .frame(height: 20)
            .cornerRadius(5)
        }
      }
    }
    .applyMargins()
  }
}

#Preview {
  GoalEstimatorView().emptyState()
}

#Preview {
  GoalEstimatorView()
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
        
        Button(action: {}, label: {
          Text("Calculate")
            .font(.subheadlineSemibold)
            .frame(maxWidth: .infinity, alignment: .center)
        })
        .tint(.primaryGreen)
        .buttonStyle(.borderedProminent)
      }
    }
    .applyMargins()
  }
}
