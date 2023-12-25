//
//  MonthRecapOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/23/23.
//

import SwiftUI
import ExpensaroUIKit
import Charts

struct MonthRecapOverviewView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  var body: some View {
    NavigationView {
      ScrollView {
        header().padding(.top, 16)
        budgetSection().padding(.top, 5)
        categoriesSection().padding(.top, 5)
      }
      .applyBounce()
      .applyMargins()
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
    
    var percentage: Text {
      return Text("30%").foregroundColor(.primaryGreen).font(.footnoteBold)
    }
  }
}

extension MonthRecapOverviewView {
  @ViewBuilder
  func header() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Your month recap for")
        .font(.headlineRegular)
        .foregroundColor(.darkGrey)
      Appearance.shared.currentMonth
        .font(.largeTitleBold)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  @ViewBuilder
  func budgetSection() -> some View {
    VStack(spacing: 10) {
      EXBaseCard {
        VStack(alignment: .leading, spacing: 20) {
          HStack(alignment: .bottom) {
            VStack {
              VStack(spacing: 0) {
                Text("Initial budget")
                  .font(.footnoteMedium)
                  .foregroundColor(.darkGrey)
                Text("$\(2000)")
                  .font(.calloutBold)
                  .foregroundColor(.black)
              }
              Rectangle()
                .fill(Color.primaryGreen)
                .frame(height: (2000 * 0.08))
                .cornerRadius(5, corners: [.topLeft,.topRight])
            }
            VStack {
              VStack(spacing: 0) {
                Text("Added funds")
                  .font(.footnoteMedium)
                  .foregroundColor(.darkGrey)
                Text("$\(780)")
                  .font(.calloutBold)
                  .foregroundColor(.black)
              }
              Rectangle()
                .fill(Color(red: 0.384, green: 0.78, blue: 0.549))
                .frame(height: (780 * 0.07))
                .cornerRadius(5, corners: [.topLeft,.topRight])
            }
            VStack {
              VStack(spacing: 0) {
                Text("Total spent")
                  .font(.footnoteMedium)
                  .foregroundColor(.darkGrey)
                Text("$\(1600)")
                  .font(.calloutBold)
                  .foregroundColor(.black)
              }
              Rectangle()
                .fill(Color(uiColor: .systemGray5))
                .frame(height: (1600 * 0.08))
                .cornerRadius(5, corners: [.topLeft,.topRight])
            }
          }
        }
      }
    }
  }
  
  @ViewBuilder
  func categoriesSection() -> some View {
    EXBaseCard {
      VStack(alignment: .leading) {
        Chart {
          ForEach(sampleStorageDetails, id: \.categoryName) { data in
            
            BarMark(
              x: .value("", data.amount),
              stacking: .normalized
            )
            .foregroundStyle(data.progressColor)
          }
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .frame(height: 35)
        .cornerRadius(5)
        .frame(maxWidth: .infinity)
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(sampleStorageDetails, id: \.categoryName) { data in
              HStack(spacing: 3) {
                Circle()
                  .fill(data.progressColor)
                  .frame(width: 7, height: 7)
                Text(data.categoryName.rawValue.capitalized)
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

#Preview {
  MonthRecapOverviewView()
}
