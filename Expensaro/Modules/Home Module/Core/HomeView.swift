//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import ExpensaroUIKit

struct HomeView: View {
  @State private var showAddBudget = false
  @State private var showAddRecurrentPayment = false
  @State private var showAddTransaction = false
  var body: some View {
    NavigationView {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 10) {
          EXLargeEmptyState(type: .noBudget, icon: Source.Images.EmptyStates.noBudget, action: {
            showAddBudget.toggle()
          })
          EXSmallEmptyState(type: .noRecurrentPayments, icon: .init(systemName: "globe"), action: {
            showAddRecurrentPayment.toggle()
          })
          EXLargeEmptyState(type: .noExpenses, icon: Source.Images.EmptyStates.noExpenses, action: {
            showAddTransaction.toggle()
          })
        }
        .applyMargins()
      }
      .sheet(isPresented: $showAddBudget, content: {
        AddBudgetView()
          .presentationDetents([.large])
      })
      .sheet(isPresented: $showAddTransaction, content: {
        AddTransactionView()
          .presentationDetents([.large])
      })
      .sheet(isPresented: $showAddRecurrentPayment, content: {
        AddRecurrentPaymentView()
          .presentationDetents([.large])
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 24))
            .padding(.bottom, 20)
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

// MARK: - Apperance
extension HomeView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Home"
  }
}
