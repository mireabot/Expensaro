//
//  TopCategoryOverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/7/23.
//

import SwiftUI
import ExpensaroUIKit

struct TopCategoryOverviewView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  
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
        
        EXBaseCard {
          VStack(alignment: .leading, spacing: 5) {
            HStack {
              ProgressView(value: 0.5, total: 1, label: {
                Text("50%").font(.bodySemibold).foregroundColor(.black)
              })
                .tint(.primaryGreen)
            }
            Text("See how much you've spent in percentage")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          }
        }
        .applyMargins()
        .padding(.top, 5)
        
        // MARK: Other categories
        Text("Check other categories")
          .font(.headlineSemibold)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity, alignment: .leading)
          .applyMargins()
          .padding(.top, 15)
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
    let title = "Top category"
    
    let backIcon = Source.Images.Navigation.back
    
    var currentMonth: Text {
      return Text("\(Source.Functions.currentMonth())").foregroundColor(.primaryGreen).font(.footnoteSemibold)
    }
  }
}


struct CustomProgressView: View {
  let progress: CGFloat

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Rectangle()
          .frame(width: geometry.size.width, height: 15)
          .opacity(0.3)
          .foregroundColor(Color(uiColor: .systemGray3))
          .cornerRadius(12)

        Rectangle()
          .frame(
            width: min(progress * geometry.size.width,
                       geometry.size.width),
            height: 15
          )
          .foregroundColor(.primaryGreen)
          .cornerRadius(12)
      }
    }
  }
}
