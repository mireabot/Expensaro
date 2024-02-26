//
//  DailyTransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/26/24.
//

import SwiftUI

struct DailyTransactionInsightsView: View {
  var body: some View {
    Group {
      EXEmptyStateView(type: .noDailyTransactionsInsights, isActive: true)
    }
  }
}

#Preview {
  DailyTransactionInsightsView()
}
