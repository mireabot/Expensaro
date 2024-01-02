//
//  CategoriesBreakdownOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/26/23.
//

import SwiftUI
import Charts
import ExpensaroUIKit

struct CategoriesBreakdownOverviewView: View {
  @ObservedObject var service: MonthRecapService
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text("Your breakdown for")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
        Text("Categories")
          .font(.titleBold)
      }
      .padding(.top, 20)
      .applyMargins()
      .frame(maxWidth: .infinity, alignment: .leading)
      
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
      .frame(height: 40)
      .cornerRadius(5)
      .applyMargins()
      
      VStack(alignment: .leading) {
        ForEach(service.groupedTransactions, id: \.section) { data in
          Section {
            HStack {
              Text(data.section.header)
                .font(.bodySemibold)
              Circle()
                .fill(data.section.progressColor)
                .frame(width: 10, height: 10)
            }
          }
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(data.totalAmountByCategory, id: \.0) { categoryName, totalAmount, categoryIcon in
              EXSmallCard(title: "$\(totalAmount.clean)", header: categoryName, image: .imageName(categoryIcon))
            }
          }
        }
      }
      .applyMargins()
      .padding(.top, 10)
      
    }
    .applyBounce()
  }
}

#Preview {
  CategoriesBreakdownOverviewView(service: .init())
}
