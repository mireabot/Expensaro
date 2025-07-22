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
  @State private var searchQuery = ""
  @AppStorage("currencySign") private var currencySign = "USD"
  var filteredCurrencies: [Currency] {
    if searchQuery.isEmpty {
      return Currency.allCurrencies
    } else {
      return Currency.allCurrencies.filter { $0.code.contains(searchQuery.uppercased()) }
    }
  }
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
          ForEach(Currency.allCurrencies, id: \.symbol) { currency in
            Button {
              currencySign = currency.code
            } label: {
              EXSelectCell(title: currency.symbol, text: currency.name, condition: currencySign == currency.code)
            }
          }
        }
        .padding(.vertical, 16)
        .applyMargins()
      }
      .scrollBounceBehavior(.basedOnSize)
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

extension CurrencySelectorView {
  @ViewBuilder
  func currencyCell() -> some View {
    ZStack(alignment: .topTrailing) {
      VStack(alignment: .leading, spacing: 0) {
        Spacer()
        Text("$")
          .font(.headlineBold)
          .foregroundColor(.black)
        Text("US Dollar")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      
      Image(systemName: "circle")
        .foregroundColor(Color(uiColor: .systemGray5))
    }
    .padding(10)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
    .frame(height: 80)
  }
}
