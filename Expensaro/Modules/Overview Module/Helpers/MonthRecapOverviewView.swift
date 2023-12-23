//
//  MonthRecapOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/23/23.
//

import SwiftUI
import ExpensaroUIKit

struct MonthRecapOverviewView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  var body: some View {
    NavigationView {
      ScrollView {
        header().padding(.top, 16)
        budgetSection().padding(.top, 5)
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
              Text("Initial budget")
                .font(.footnoteMedium)
                .foregroundColor(.darkGrey)
              ZStack(alignment: .bottom) {
                Rectangle()
                  .fill(Color.primaryGreen)
                  .frame(height: (2000 * 0.08))
                  .cornerRadius(16, corners: [.topLeft,.topRight])
                Text("$2000")
                  .font(.headlineBold)
                  .foregroundColor(.white)
                  .padding(.bottom, 10)
              }
            }
            VStack {
              Text("Added funds")
                .font(.footnoteMedium)
                .foregroundColor(.darkGrey)
              ZStack(alignment: .bottom) {
                Rectangle()
                  .fill(Color(uiColor: .green).opacity(0.45))
                  .frame(height: (780 * 0.07))
                  .cornerRadius(16, corners: [.topLeft,.topRight])
                
                Text("$780")
                  .font(.headlineBold)
                  .foregroundColor(.black)
                  .padding(.bottom, 10)
              }
            }
            VStack {
              Text("Total spent")
                .font(.footnoteMedium)
                .foregroundColor(.darkGrey)
              ZStack(alignment: .bottom) {
                Rectangle()
                  .fill(Color(uiColor: .quaternarySystemFill))
                  .frame(height: (1600 * 0.08))
                  .cornerRadius(16, corners: [.topLeft,.topRight])
                
                Text("$1600")
                  .font(.headlineBold)
                  .foregroundColor(.black)
                  .padding(.bottom, 10)
              }
            }
          }
        }
      }
      
      EXBaseCard {
        VStack {
          HStack(alignment: .top, spacing: 30) {
            VStack(alignment: .leading, spacing: 5) {
              Text("Budget gap")
                .font(.footnoteMedium)
                .foregroundColor(.darkGrey)
              Text("$\(1180)")
                .font(.title3Bold)
                .foregroundColor(.black)
              HStack(spacing: 0) {
                Source.Images.System.arrowUp
                  .resizable()
                  .frame(width: 20, height: 20)
                  .foregroundColor(.green)
                Text("\(59)%")
                  .font(.footnoteSemibold)
                  .foregroundColor(.green)
              }
            }
            VStack(alignment: .leading, spacing: 5) {
              Text("Future budget")
                .font(.footnoteMedium)
                .foregroundColor(.darkGrey)
              Text("~$\(1500)")
                .font(.title3Bold)
                .foregroundColor(.black)
              HStack(spacing: 0) {
                Source.Images.System.arrowDown
                  .resizable()
                  .frame(width: 20, height: 20)
                  .foregroundColor(.red)
                Text("\(25)%")
                  .font(.footnoteSemibold)
                  .foregroundColor(.red)
              }
            }
            VStack(alignment: .leading, spacing: 5) {
              Text("Budget Mastery")
                .font(.footnoteMedium)
                .foregroundColor(.darkGrey)
              Text("\(43)%")
                .font(.title3Bold)
                .foregroundColor(.black)
              Text("Yellow zone")
                .font(.footnoteSemibold)
                .foregroundColor(.yellow)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .center)
      }
    }
  }
}


#Preview {
  MonthRecapOverviewView()
}
