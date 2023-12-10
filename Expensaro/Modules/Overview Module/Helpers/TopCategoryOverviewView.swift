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
        Text("Amazon")
          .foregroundColor(.black)
          .font(.titleBold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .applyMargins()
          .padding(.top, 16)
        // MARK: Top Category breakdown
        HStack(alignment: .top, spacing: 5) {
          VStack(alignment: .leading, spacing: 0) {
            Text("Total amount spent")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
            Spacer()
            Text("$1450.99")
              .font(.system(size: 30, weight: .bold))
              .foregroundColor(.primaryGreen)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(12)
          .background(Color.backgroundGrey)
          .cornerRadius(16)
          
          VStack(alignment: .leading, spacing: 0) {
            Text("Transactions made")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
            Spacer()
            Text("22")
              .font(.system(size: 30, weight: .bold))
              .foregroundColor(.primaryGreen)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(12)
          .background(Color.backgroundGrey)
          .cornerRadius(16)
        }
        .applyMargins()
      }
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
  }
}
