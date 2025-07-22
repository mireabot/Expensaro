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
  var body: some View {
    NavigationView {
      ScrollView(content: {
        VStack(spacing: 15) {
          Button {
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(CurrencySelectorView()))
          } label: {
            settingsRow(icon: Source.Images.EmptyStates.noBudget, title: "Currency")
          }
          .buttonStyle(EXPlainButtonStyle())
        }
        .padding(.top, 16)
        .applyMargins()
      })
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

extension AppSettingsView {
  @ViewBuilder
  func settingsRow(icon: Image, title: String) -> some View {
    EXBaseCard {
      HStack(alignment: .center) {
        icon
          .foregroundColor(.primaryGreen)
        Text(title)
          .font(.headlineMedium)
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundColor(.black)
      }
      .padding(4)
    }
  }
}
