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
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text("Your breakdown for")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
        Text("Categories")
          .font(.titleBold)
      }
      .padding(.top, 16)
      .applyMargins()
      .frame(maxWidth: .infinity, alignment: .leading)
      
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
      .frame(height: 40)
      .cornerRadius(5)
      .applyMargins()
      
      VStack(alignment: .leading) {
        Section {
          HStack {
            Text("Lifestyle")
              .font(.bodySemibold)
            Circle()
              .fill(Color(red: 0.612, green: 0.22, blue: 0.282))
              .frame(width: 10, height: 10)
          }
        }
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
          ForEach(sampleStorageDetails) { item in
            EXSmallCard(title: "$\(item.amount.clean)", header: item.categoryName.header, image: Source.Strings.Categories.Images.car)
          }
        }
        
        Section {
          HStack {
            Text("Lifestyle")
              .font(.bodySemibold)
            Circle()
              .fill(Color(red: 0.612, green: 0.22, blue: 0.282))
              .frame(width: 10, height: 10)
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
  CategoriesBreakdownOverviewView()
}
