//
//  DailyTransactionsOnboarding.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/22/24.
//

import SwiftUI
import ExpensaroUIKit

struct DailyTransactionsOnboarding: View {
  // MARK: Essential
  @Environment(\.dismiss) var makeDismiss
  @AppStorage("dailyTransactionsONB") private var isShownOnboarding = false
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 3, content: {
        Text(Appearance.shared.header)
          .font(.titleBold)
        Text(Appearance.shared.title)
          .font(.headlineRegular)
          .foregroundStyle(Color.darkGrey)
      })
      .frame(maxWidth: .infinity, alignment: .leading)
      .applyMargins()
      .padding(.top, 16)
      
      VStack(spacing: 0) {
        EXBottomInfoView(config: ("Tailor Your Expense Templates","Begin with crafting your daily transaction templates to reflect your routine expenses. From a $2.90 subway ride to your morning coffee", false, ""), action: {}, bottomView: {
          Image("dailyONB1")
            .frame(maxWidth: .infinity)
            .background(Color.backgroundGrey)
            .cornerRadius(10)
        })
        
        EXBottomInfoView(config: ("Your Daily Expenses, Simplified","Once your templates are set, adding them as expenses is just a tap away. Select any template, like your subway ride, and add it to your expenses instantly", false, ""), action: {}, bottomView: {
          Image("dailyONB2")
            .frame(maxWidth: .infinity)
            .background(Color.backgroundGrey)
            .cornerRadius(10)
        })
      }
      .applyMargins()
    }
    .applyBounce()
    .safeAreaInset(edge: .bottom) {
      VStack {
        Button(action: {
          isShownOnboarding = true
          makeDismiss()
        }, label: {
          Text("Get Started")
            .font(.headlineSemibold)
        })
        .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
        .applyMargins()
      }
      .padding(5)
      .background(Color.white)
    }
  }
}

#Preview {
  DailyTransactionsOnboarding()
}

extension DailyTransactionsOnboarding {
  struct Appearance {
    static let shared = Appearance()
    
    let header = "Meet Daily Transactions"
    let title = "Simplify your expense tracking by creating and adding daily transactions with just one tap"
  }
}
