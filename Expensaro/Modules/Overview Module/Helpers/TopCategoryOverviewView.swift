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
  
  let maxXaxis = topCategoriesData.map { $0.amount }.max()! + 100
  var body: some View {
    NavigationView {
      ScrollView {
        EXBaseCard {
          VStack(alignment: .leading, spacing: 5) {
            Text("Shopping")
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
              Text("$1500")
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
              Text("22")
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
        
        VStack {
          EXChartBar(value: 1500, text: "From your monthly budget", maxValue: 2000)
        }
        .padding(.top, 5)
        
        // MARK: Other categories
        Text("Check other categories")
          .font(.headlineSemibold)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity, alignment: .leading)
          .applyMargins()
          .padding(.top, 15)
        
        VStack(alignment: .leading, spacing: 10) {
          ForEach(topCategoriesData) { data in
            TopCategoryBar(total: 2000, category: data)
          }
        }
        
        EXBaseCard {
          Text("Percentages shown are based on your monthly budget")
            .font(.footnoteRegular)
            .foregroundColor(.darkGrey)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .applyMargins()
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
  TopCategoryOverviewView()
}

// MARK: - Apperance
extension TopCategoryOverviewView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Top category analytics"
    
    let backIcon = Source.Images.Navigation.back
    
    var currentMonth: Text {
      return Text("\(Source.Functions.currentMonth())").foregroundColor(.primaryGreen).font(.footnoteSemibold)
    }
  }
}


struct TopCategoryBar: View {
  var total: Int
  var category: TopCategories
  private var screenWidth: CGFloat {UIScreen.main.bounds.size.width }
  private var maxWidth: CGFloat { screenWidth - 32 }
  
  private var insetWidth: CGFloat {
    return CGFloat((category.amount * maxWidth) / CGFloat(total))
  }
  private var percentage: Double {
    return (category.amount / 2000) * 100
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
        .frame(width: self.insetWidth, height: 50)
        .cornerRadius(12)
      
      VStack(alignment: .leading, spacing: 3) {
        Text("\(category.name)")
          .font(.calloutBold)
        Text("$\(category.amount.clean)")
          .font(.footnoteSemibold)
          .foregroundColor(.primaryGreen)
      }
      .padding(.leading, 12)
    }
  }
}
