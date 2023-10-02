//
//  HomeView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI
import ExpensaroUIKit

struct HomeView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var showAddBudget = false
  @State private var showAddRecurrentPayment = false
  @State private var showAddTransaction = false
  
  @State private var showUpdateBudget = false
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        ScrollView(.vertical, showsIndicators: false) {
          VStack {
            budgetSection()
            recurrentPaymentsRow()
            transactionsPreview()
          }
          .applyMargins()
          .padding(.top, 20)
        }
        bottomActionButton()
          .padding(16)
      }
      .sheet(isPresented: $showAddBudget, content: {
        AddBudgetView(type: .addBudget)
          .presentationDetents([.large])
      })
      .sheet(isPresented: $showUpdateBudget, content: {
        AddBudgetView(type: .updateBudget)
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
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(SettingsView()))
          } label: {
            Appearance.shared.settingsIcon
              .foregroundColor(.primaryGreen)
          }
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
    
    let settingsIcon = Source.Images.System.settings
  }
}

// MARK: - Helper Views
extension HomeView {
  @ViewBuilder
  func bottomActionButton() -> some View {
    VStack {
      Menu {
        Button(action: { showAddTransaction.toggle() }) {
          Label("Add transaction", image: "buttonTransaction")
        }
        
        Button(action: { showAddRecurrentPayment.toggle() }) {
          Label("Add recurrent payment", image: "buttonRecurrent")
        }
        
      } label: {
        ZStack {
          Circle()
            .fill(Color.secondaryYellow)
            .frame(width: 60, height: 60)
          Source.Images.ButtonIcons.add
            .foregroundColor(.primaryGreen)
        }
      }
      .font(.mukta(.regular, size: 15))
      .menuOrder(.fixed)
    }
  }
}

extension HomeView {
  @ViewBuilder
  func emptyScrollView() -> some View {
    VStack(spacing: 10) {
      EXLargeEmptyState(type: .noBudget, icon: Source.Images.EmptyStates.noBudget, action: {
        showAddBudget.toggle()
      })
      EXSmallEmptyState(type: .noRecurrentPayments, action: {
        showAddRecurrentPayment.toggle()
      })
      EXLargeEmptyState(type: .noExpenses, icon: Source.Images.EmptyStates.noExpenses, action: {
        showAddTransaction.toggle()
      })
    }
    .padding(.top, 16)
    .applyMargins()
  }
  
  @ViewBuilder
  func budgetSection() -> some View {
    VStack(alignment: .center, spacing: -5) {
      Text("Your budget")
        .font(.mukta(.regular, size: 17))
        .foregroundColor(.darkGrey)
      Text("$ 5000 USD")
        .font(.mukta(.bold, size: 34))
        .foregroundColor(.black)
      
      Button {
        showUpdateBudget.toggle()
      } label: {
        HStack {
          Source.Images.ButtonIcons.add
            .foregroundColor(.primaryGreen)
          Text("Add money")
            .font(.mukta(.semibold, size: 15))
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(SmallButtonStyle())
      .padding(.top, 20)
    }
  }
  
  @ViewBuilder
  func recurrentPaymentsRow() -> some View {
    VStack(spacing: 15) {
      HStack {
        Text("Recurrent payments")
          .font(.mukta(.semibold, size: 17))
          .foregroundColor(.black)
        Spacer()
        Button(action: {
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RecurrentPaymentsListView()))
        }) {
          Text("See all")
            .font(.mukta(.semibold, size: 15))
        }
        .buttonStyle(TextButtonStyle())
      }
      .padding(.top, 30)
      HStack {
        EXRecurrentCell(paymentData: RecurrentPayment.recurrentPayments[0])
        EXRecurrentCell(paymentData: RecurrentPayment.recurrentPayments[1])
        EXRecurrentCell(paymentData: RecurrentPayment.recurrentPayments[2])
      }
    }
  }
  
  @ViewBuilder
  func transactionsPreview() -> some View {
    VStack(spacing: 15) {
      HStack {
        VStack(alignment: .leading, spacing: -3) {
          Text("Spendings for")
            .font(.mukta(.regular, size: 15))
            .foregroundColor(.darkGrey)
          Text("\(Source.Functions.currentMonth())")
            .font(.mukta(.semibold, size: 20))
        }
        Spacer()
        Button(action: {}) {
          Text("See all")
            .font(.mukta(.medium, size: 15))
        }
        .buttonStyle(SmallButtonStyle())
      }
      Divider()
      VStack {
        TransactionCell(icon: Image(Source.Strings.Categories.Images.car), name: "Gas station", date: .now, amount: 15.78, type: "Credit")
        TransactionCell(icon: Image(Source.Strings.Categories.Images.groceries), name: "Groceries", date: .now, amount: 50.25, type: "Debit")
        TransactionCell(icon: Image(Source.Strings.Categories.Images.subscriptions), name: "Monthly Subscription", date: .now, amount: 9.99, type: "Debit")
      }
      .padding(.bottom, 5)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background(.white)
    .cornerRadius(10)
    .shadowXS()
    .padding(.top, 15)
  }
}
