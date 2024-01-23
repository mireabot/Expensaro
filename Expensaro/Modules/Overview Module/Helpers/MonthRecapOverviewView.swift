//
//  MonthRecapOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/23/23.
//

import SwiftUI
import ExpensaroUIKit
import Charts
import RealmSwift

struct MonthRecapOverviewView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @AppStorage("currencySign") private var currencySign = "$"
  
  @ObservedObject var service: MonthRecapService
  // MARK: Presentation
  @State private var showCategoriesBreakdown = false
  var body: some View {
    NavigationView {
      ScrollView {
        header().padding(.top, 16)
        budgetSection().padding(.top, 5)
        categoriesSection().padding(.top, 10)
        goalsSection().padding(.top, 10)
      }
      .applyBounce()
      .applyMargins()
      .sheet(isPresented: $showCategoriesBreakdown, content: {
        CategoriesBreakdownOverviewView(service: service)
          .presentationDetents([.fraction(0.95)])
          .presentationDragIndicator(.visible)
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .foregroundColor(.black)
          }
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
      Text(service.recapMonth)
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
          Chart(service.budgetSet) {
            BarMark(x: .value("", $0.amount),
                    y: .value("", $0.tag),
                    
                    stacking: .standard
            )
            .foregroundStyle($0.color)
            .cornerRadius(5)
          }
          .frame(height: 100)
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .chartLegend(.hidden)
          
          VStack(alignment: .leading) {
            ForEach(service.budgetSet) { data in
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
                Text("\(data.amount, format: .currency(code: "USD"))")
                  .font(.system(.footnote, weight: .semibold))
              }
            }
          }
        }
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
        .disabled(service.groupedTransactions.isEmpty)
        .opacity(service.groupedTransactions.isEmpty ? 0 : 1)
      }
      if !service.groupedTransactions.isEmpty {
        EXBaseCard {
          VStack(alignment: .leading) {
            Chart {
              ForEach(service.groupedTransactions, id: \.section) { data in
                
                BarMark(
                  x: .value("", data.totalAmount),
                  stacking: .normalized
                )
                .foregroundStyle(data.section.progressColor)
              }
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 35)
            .cornerRadius(5)
            .frame(maxWidth: .infinity)
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 10) {
                ForEach(service.groupedTransactions, id: \.section) { data in
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
      if service.goalTotalContribution != 0 {
        EXBaseCard {
          VStack {
            HStack {
              VStack(alignment: .leading, spacing: 3, content: {
                Text("\(currencySign)\(service.goalTotalContribution.clean)")
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
              ForEach(service.goalContributionBreakdown) { goalData in
                HStack {
                  Text(goalData.name)
                    .font(.footnote)
                  Spacer()
                  Text("\(currencySign)\(goalData.totalAmount.clean)")
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
  MonthRecapOverviewView(service: .init())
    .environment(\.realmConfiguration, RealmMigrator.configuration)
}
