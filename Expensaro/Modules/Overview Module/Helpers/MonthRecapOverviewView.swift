//
//  MonthRecapOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/23/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import Charts

struct MonthRecapOverviewView: View {
  // MARK: Essential
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  let recap: MonthRecap
  // MARK: Presentation
  @State private var showCategoriesBreakdown = false
  var body: some View {
    ScrollView {
      header()
        .applyMargins()
        .padding(.top, 16)
      budgetSection()
        .applyMargins()
        .padding(.top, 5)
      categoriesSection()
        .applyMargins()
        .padding(.top, 10)
      goalsSection()
        .applyMargins()
        .padding(.vertical, 10)
    }
    .scrollBounceBehavior(.basedOnSize)
    .scrollIndicators(.hidden)
    .sheet(isPresented: $showCategoriesBreakdown, content: {
      CategoriesBreakdownOverviewView(recap: recap)
        .presentationDetents([.fraction(0.95)])
        .presentationDragIndicator(.visible)
    })
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          router.back()
        } label: {
          Appearance.shared.backIcon
            .foregroundColor(.black)
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Button("Provide feedback") {
            router.presentFullScreenCover(.feedback(topic: "Month Recap"))
          }
        } label: {
          Image(systemName: "ellipsis")
            .foregroundStyle(.black)
        }
      }
    }
  }
}

// MARK: - Apperance
extension MonthRecapOverviewView {
  struct Appearance {
    static let shared = Appearance()
    
    let backIcon = Source.Images.Navigation.back
    
    var currentMonth: Text {
      return Text("\(Source.Functions.currentMonth(date: .now))") .font(.largeTitleBold)
    }
  }
}

// MARK: - Components Views
extension MonthRecapOverviewView {
  @ViewBuilder
  func header() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Your month recap for")
        .font(.headlineRegular)
        .foregroundColor(.darkGrey)
      Text(recap.recapMonth)
        .font(.largeTitleBold)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  @ViewBuilder
  func budgetSection() -> some View {
    VStack(spacing: 10) {
      HStack {
        Text("Budget activity")
          .font(.subheadlineSemibold)
          .foregroundColor(.black)
        Spacer()
      }
      EXBaseCard {
        VStack(alignment: .leading) {
          Chart(recap.budgetSet) {
            BarMark(x: .value("", $0.amount),
                    y: .value("", $0.tag),
                    
                    stacking: .standard
            )
            .foregroundStyle($0.color)
            .cornerRadius(5)
          }
          .frame(height: 100)
          //.chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .chartLegend(.hidden)
          
          VStack(alignment: .leading) {
            ForEach(recap.budgetSet) { data in
              HStack {
                HStack(spacing: 5) {
                  RoundedRectangle(cornerRadius: 2)
                    .fill(data.color)
                    .frame(width: 10, height: 10)
                  Text(data.name)
                    .font(.footnote)
                    .foregroundColor(.darkGrey)
                }
                Spacer()
                Text("\(data.amount.formattedAsCurrencySolid(with: currencySign))")
                  .font(.footnoteSemibold)
              }
            }
          }
        }
      }
      EXBaseCard {
        VStack(alignment: .leading, spacing: 3) {
          Text("\(recap.budgetData.3.formattedAsCurrency(with: currencySign))")
            .font(.headlineBold)
          Text("Unused Budget")
            .font(.footnoteRegular)
            .foregroundStyle(Color.darkGrey)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
  
  @ViewBuilder
  func categoriesSection() -> some View {
    VStack(spacing: 10) {
      HStack {
        Text("Categories breakdown")
          .font(.subheadlineSemibold)
          .foregroundColor(.black)
        Spacer()
        Button(action: {
          showCategoriesBreakdown.toggle()
        }, label: {
          Text("Learn more")
            .foregroundColor(.primaryGreen)
            .font(.footnoteMedium)
        })
        .disabled(recap.groupedTransactions.isEmpty)
        .opacity(recap.groupedTransactions.isEmpty ? 0 : 1)
      }
      if !recap.groupedTransactions.isEmpty {
        EXBaseCard {
          VStack(alignment: .leading) {
            Chart {
              ForEach(recap.groupedTransactions, id: \.section) { data in
                
                BarMark(
                  x: .value("", data.totalAmount),
                  stacking: .normalized
                )
                .foregroundStyle(data.section.progressColor)
              }
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 30)
            .cornerRadius(5)
            .frame(maxWidth: .infinity)
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 10) {
                ForEach(recap.groupedTransactions, id: \.section) { data in
                  HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 2)
                      .fill(data.section.progressColor)
                      .frame(width: 7, height: 7)
                    Text(data.section.header)
                      .font(.footnoteRegular)
                      .foregroundColor(.darkGrey)
                  }
                  .frame(maxWidth: .infinity)
                }
              }
            }
          }
        }
      } else {
        EXEmptyStateView(type: .noRecapTransactions)
      }
    }
  }
  
  @ViewBuilder
  func goalsSection() -> some View {
    VStack(spacing: 10) {
      HStack {
        Text("Goals analytics")
          .font(.subheadlineSemibold)
          .foregroundColor(.black)
        Spacer()
      }
      if recap.goalTotalContribution != 0 {
        EXBaseCard {
          VStack {
            HStack {
              VStack(alignment: .leading, spacing: 3, content: {
                Text("\(recap.goalTotalContribution.formattedAsCurrencySolid(with: currencySign))")
                  .font(.title3Bold)
                Text("You contributed towards goals")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
              })
              Spacer()
              Image(Source.Images.Tabs.goals)
                .foregroundColor(.primaryGreen)
            }
            Divider().padding(.vertical, 5)
            VStack(spacing: 5) {
              ForEach(recap.goalContributionBreakdown) { goalData in
                HStack {
                  Text(goalData.name)
                    .font(.footnote)
                  Spacer()
                  Text("\(goalData.totalAmount.formattedAsCurrencySolid(with: currencySign))")
                    .font(.footnoteBold)
                }
              }
            }
          }
        }
      } else {
        EXEmptyStateView(type: .noRecapGoals)
      }
    }
  }
}

#Preview {
  MonthRecapOverviewView(recap: MonthRecap(budgets: [], transactions: [], goalTransactions: []))
}
