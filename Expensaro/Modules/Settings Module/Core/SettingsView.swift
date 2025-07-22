//
//  SettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit
import WishKit
import StoreKit

struct SettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @Environment(\.requestReview) var requestReview
  @State private var selectedCategory = ""
  
  let appIcon = Bundle.main.icon
  let appVersion = Bundle.main.appVersion
  
  @State private var showRequestSheet = false
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 5) {
          Image(uiImage: appIcon!)
            .resizable()
            .frame(width: 70, height: 70)
            .aspectRatio(contentMode: .fit)
          
          Text("Version \(appVersion)")
            .font(.system(.subheadline, weight: .regular))
            .foregroundColor(.darkGrey)
        }
        .padding(.top, 20)
        
        VStack {
          HStack {
            EXSettingsCell(category: $selectedCategory,
                           config: (Source.Strings.SettingsType.categories.title, Source.Strings.SettingsType.categories.text),
                           icon: Source.Images.Settings.categories,
                           action: {navigateTo()})
            EXSettingsCell(category: $selectedCategory,
                           config: (Source.Strings.SettingsType.reminders.title, Source.Strings.SettingsType.reminders.text),
                           icon: Source.Images.Settings.reminders,
                           action: {navigateTo()})
          }
          HStack {
            EXSettingsCell(category: $selectedCategory,
                           config: (Source.Strings.SettingsType.appSettings.title, Source.Strings.SettingsType.appSettings.text),
                           icon: Source.Images.System.appTools,
                           action: {navigateTo()})
            EXSettingsCell(category: $selectedCategory,
                           config: (Source.Strings.SettingsType.resetAccount.title, Source.Strings.SettingsType.resetAccount.text),
                           icon: Source.Images.Settings.resetData,
                           action: {navigateTo()})
          }
          HStack {
            EXSettingsCell(category: $selectedCategory,
                           config: (Source.Strings.SettingsType.contact.title, Source.Strings.SettingsType.contact.text),
                           icon: Source.Images.Settings.contact,
                           action: {navigateTo()})
            EXSettingsCell(category: $selectedCategory,
                           config: (Source.Strings.SettingsType.rateApp.title, Source.Strings.SettingsType.rateApp.text),
                           icon: Source.Images.Settings.rateApp,
                           action: {navigateTo()})
          }
          EXSettingsCell(category: $selectedCategory,
                         config: (Source.Strings.SettingsType.wishKit.title, Source.Strings.SettingsType.wishKit.text),
                         icon: Source.Images.Settings.request,
                         action: {navigateTo()})
        }
        .applyMargins()
        .padding(.vertical, 16)
        .sheet(isPresented: $showRequestSheet) {
          WishView()
        }
      }
      .scrollBounceBehavior(.basedOnSize)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.white, for: .bottomBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
        
        if Source.adminMode {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              router.pushTo(view: EXNavigationViewBuilder.builder.makeView(DebugMenuView()))
            } label: {
              Appearance.shared.debugIcon
                .font(.callout)
                .foregroundColor(.black)
            }
          }
        }
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

// MARK: - Appearance
extension SettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Settings"
    
    let backIcon = Source.Images.Navigation.back
    let debugIcon = Source.Images.System.appTools
  }
}

extension SettingsView {
  private func navigateTo() {
    switch selectedCategory {
    case "Categories": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(CategoriesSettingsView()))
    case "Reminders": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RemindersSettingsView()))
    case "Export Data": print("Navigation error")
    case "General Settings": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(AppSettingsView()))
    case "Reset Data": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(EraseDataSettingsView()))
    case "Contact": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(ContactSettingsView(topic: "General", isCalled: false)))
    case "Rate App": requestReview()
    case "Features Hub": showRequestSheet.toggle()
    default: print("Navigation error")
    }
  }
}

extension Bundle {
  var icon: UIImage? {
    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
       let lastIcon = iconFiles.last {
      return UIImage(named: lastIcon)
    }
    return nil
  }
  
  var appVersion: String {
    if let version = infoDictionary?["CFBundleShortVersionString"] as? String {
      return version
    }
    return "Unknown"
  }
}

struct WishView: View {
  init() {
    WishKit.configure(with: Source.wishKEY)
    WishKit.config.statusBadge = .show
    WishKit.config.commentSection = .hide
    WishKit.config.dropShadow = .hide
    WishKit.theme.tertiaryColor = .set(light: .white, dark: .black)
    WishKit.theme.secondaryColor = .set(light: .backgroundGrey, dark: .red)
    WishKit.config.buttons.saveButton.textColor = .set(light: .white, dark: .white)
  }
  var body: some View {
    WishKit.view.withNavigation()
  }
}
