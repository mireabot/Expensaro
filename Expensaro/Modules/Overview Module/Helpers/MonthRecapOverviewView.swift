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
      return Text("\(Source.Functions.currentMonth())") .font(.largeTitleBold)
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
        VStack(alignment: .leading, spacing: 20) {
          HStack(alignment: .bottom) {
            VStack {
              VStack(spacing: 0) {
                Text("Initial budget")
                  .font(.footnoteMedium)
                  .foregroundColor(.darkGrey)
                Text("$\(service.budgetData.0.clean)")
                  .font(.calloutBold)
                  .foregroundColor(.black)
              }
              Rectangle()
                .fill(Color.primaryGreen)
                .frame(height: (service.budgetData.0 * 0.08))
                .cornerRadius(5, corners: [.topLeft,.topRight])
            }
            VStack {
              VStack(spacing: 0) {
                Text("Added funds")
                  .font(.footnoteMedium)
                  .foregroundColor(.darkGrey)
                Text("$\(service.budgetData.1.clean)")
                  .font(.calloutBold)
                  .foregroundColor(.black)
              }
              Rectangle()
                .fill(Color(red: 0.384, green: 0.78, blue: 0.549))
                .frame(height: (service.budgetData.1 * 0.08))
                .cornerRadius(5, corners: [.topLeft,.topRight])
            }
            VStack {
              VStack(spacing: 0) {
                Text("Total spent")
                  .font(.footnoteMedium)
                  .foregroundColor(.darkGrey)
                Text("$\(service.budgetData.2.clean)")
                  .font(.calloutBold)
                  .foregroundColor(.black)
              }
              Rectangle()
                .fill(Color(uiColor: .systemGray5))
                .frame(height: (service.budgetData.2 * 0.08))
                .cornerRadius(5, corners: [.topLeft,.topRight])
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
      }
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
                  Circle()
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
      if service.goalsData != 0 {
        EXBaseCard {
          HStack {
            VStack(alignment: .leading, spacing: 3, content: {
              Text("$\(service.goalsData.clean)")
                .font(.title3Bold)
              Text("You contributed towards goals")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            })
            Spacer()
            Image(Source.Images.Tabs.goals)
              .foregroundColor(.primaryGreen)
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
