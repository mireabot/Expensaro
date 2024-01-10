//
//  CurrencySelectorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/10/24.
//

import SwiftUI
import ExpensaroUIKit

struct CurrencySelectorView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @AppStorage("currencySign") private var currencySign = "$"
  var body: some View {
    NavigationView {
      List(Currency.allCurrencies, id: \.symbol) { currency in
        Button {
          currencySign = currency.symbol
        } label: {
          HStack {
            VStack(alignment: .leading, spacing: 3) {
              Text(currency.symbol)
                .font(.headlineBold)
              Text(currency.name)
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
            }
            Spacer()
            Source.Images.Navigation.checkmark
              .foregroundColor(.primaryGreen)
              .opacity(currencySign == currency.symbol ? 1 : 0)
          }
          .background(.white)
        }
        .listRowSeparator(.hidden)
        .buttonStyle(EXPlainButtonStyle())
      }
      .listStyle(.plain)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

#Preview {
  CurrencySelectorView()
}

// MARK: - Appearance
extension CurrencySelectorView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Select currency"
    
    let backIcon = Source.Images.Navigation.back
  }
}
