//
//  AppSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/9/24.
//

import SwiftUI
import ExpensaroUIKit

struct AppSettingsView: View {
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
  AppSettingsView()
}

// MARK: - Appearance
extension AppSettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "App Settings"
    
    let backIcon = Source.Images.Navigation.back
  }
}
