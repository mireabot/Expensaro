//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import ExpensaroUIKit

struct HomeView: View {
  var body: some View {
    NavigationView {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 10) {
          EXLargeEmptyState(type: .noBudget, icon: .init(systemName: "globe"), action: {})
          EXSmallEmptyState(type: .noRecurrentPayments, icon: .init(systemName: "globe"), action: {})
          EXLargeEmptyState(type: .noExpenses, icon: .init(systemName: "globe"), action: {})
        }
        .applyMargins()
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("Home")
            .font(.mukta(.medium, size: 24))
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
