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
    VStack {
      EXBaseCard {
        VStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .top, spacing: 0, content: {
            VStack(alignment: .leading, spacing: 3) {
              Text("Goal success rate")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
              Text("24%")
                .font(.title2Bold)
            }
            Spacer()
            Button(action: {}, label: {
              Image(systemName: "arrow.clockwise")
                .foregroundColor(.primaryGreen)
            })
          })
          Divider()
          VStack(alignment: .leading, spacing: 3, content: {
            Text("High risk")
              .font(.headlineBold)
              .foregroundColor(.red)
            Text("Starting this goal now will be challenging. It may be wise to wait until your situation improves")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          })
        }
      }
      
      EXBaseCard {
        VStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .top, spacing: 0, content: {
            VStack(alignment: .leading, spacing: 3) {
              Text("Goal success rate")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
              Text("57%")
                .font(.title2Bold)
            }
            Spacer()
            Button(action: {}, label: {
              Image(systemName: "arrow.clockwise")
                .foregroundColor(.primaryGreen)
            })
          })
          Divider()
          VStack(alignment: .leading, spacing: 3, content: {
            Text("Moderate risk")
              .font(.headlineBold)
              .foregroundColor(.yellow)
            Text("With careful budgeting and planning, initiating this goal could be feasible")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          })
        }
      }
      
      EXBaseCard {
        VStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .top, spacing: 0, content: {
            VStack(alignment: .leading, spacing: 3) {
              Text("Goal success rate")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
              Text("78%")
                .font(.title2Bold)
            }
            Spacer()
            Button(action: {}, label: {
              Image(systemName: "arrow.clockwise")
                .foregroundColor(.primaryGreen)
            })
          })
          Divider()
          VStack(alignment: .leading, spacing: 3, content: {
            Text("No risk")
              .font(.headlineBold)
              .foregroundColor(.green)
            Text("Your financials are looking healthy for this goal. It's a favorable time to get started!")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          })
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
