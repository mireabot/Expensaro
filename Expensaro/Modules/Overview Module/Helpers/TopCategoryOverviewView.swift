//
//  TopCategoryOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/7/23.
//

import SwiftUI
import ExpensaroUIKit
import Charts

struct TopCategoryOverviewView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @AppStorage("currencySign") private var currencySign = "$"
  @ObservedObject var service : TopCategoryManager
  var body: some View {
    NavigationView {
      ScrollView {
        EXBaseCard {
          VStack(alignment: .leading, spacing: 5) {
            Text(service.topCategory.0)
              .font(.title2Bold)
              .foregroundColor(.black)
            Text("You top category for \(Appearance.shared.currentMonth)")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .applyMargins()
        .padding(.top, 20)
        
        // MARK: Top Category breakdown
        HStack {
          EXBaseCard {
            VStack(alignment: .leading, spacing: 3) {
              Text("\(currencySign)\(service.topCategory.1.clean)")
                .font(.title3Bold)
                .foregroundColor(.black)
              Text("Total amount spent")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          EXBaseCard {
            VStack(alignment: .leading, spacing: 3) {
              Text("\(service.topCategory.2)")
                .font(.title3Bold)
                .foregroundColor(.black)
              Text("Transactions made")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .applyMargins()
        .padding(.top, 5)
        
        EXBaseCard(content: {
          VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 0, content: {
              Text("\(service.topCategoryCut.clean)%")
                .font(.title3Bold)
              Text("Based on combined monthly budget")
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            })
            EXChartBar(value: service.topCategory.1, maxValue: Int(service.combinedBudget), height: 15, radius: 5, margin: 56)
          }
        })
        .padding(.top, 5)
        
        // MARK: Other categories
        Text("Check other categories")
          .font(.headlineSemibold)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity, alignment: .leading)
          .applyMargins()
          .padding(.top, 5)
        
        VStack(alignment: .leading, spacing: 10) {
          ForEach(service.otherCategories, id: \.0) { data in
            TopCategoryBar(total: Int(service.combinedBudget), category: data)
          }
        }
        
        EXBaseCard {
          Text("Percentages shown are based on your combined monthly budget")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .applyMargins()
        .padding(.bottom, 10)
      }
      .applyBounce()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.headlineMedium)
        }
        
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

#Preview {
  TopCategoryOverviewView(service: .init())
}

// MARK: - Apperance
extension TopCategoryOverviewView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Top category analytics"
    
    let backIcon = Source.Images.Navigation.back
    
    var currentMonth: Text {
      return Text("\(Source.Functions.currentMonth(date: .now))").foregroundColor(.primaryGreen).font(.footnoteSemibold)
    }
  }
}


struct TopCategoryBar: View {
  @AppStorage("currencySign") private var currencySign = "$"
  var total: Int
  var category: (String, Double)
  private var screenWidth: CGFloat {UIScreen.main.bounds.size.width }
  private var maxWidth: CGFloat { screenWidth - 32 }
  
  private var insetWidth: CGFloat {
    return CGFloat((category.1 * maxWidth) / CGFloat(total))
  }
  private var percentage: Double {
    return (category.1 / Double(total)) * 100
  }
  var body: some View {
    ZStack(alignment: .leading) {
      ZStack(alignment: .trailing) {
        Rectangle()
          .fill(Color.backgroundGrey)
          .frame(width: self.maxWidth, height: 50)
          .cornerRadius(12)
        
        Text("\(percentage.clean)%")
          .font(.calloutSemibold)
          .foregroundColor(.darkGrey)
          .padding(.trailing, 12)
      }
      Rectangle()
        .fill(Color(uiColor: .quaternarySystemFill))
        .frame(width: self.insetWidth >= self.maxWidth ? self.maxWidth : self.insetWidth, height: 50)
        .cornerRadius(12)
      
      VStack(alignment: .leading, spacing: 3) {
        Text("\(category.0)")
          .font(.calloutBold)
        Text("\(currencySign)\(category.1.clean)")
          .font(.footnoteSemibold)
          .foregroundColor(.primaryGreen)
      }
      .padding(.leading, 12)
    }
  }
}
