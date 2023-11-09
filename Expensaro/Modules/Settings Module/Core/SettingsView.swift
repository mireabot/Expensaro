//
//  SettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit

struct SettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var selectedCategory = ""
  
  let appIcon = Bundle.main.icon
  let appVersion = Bundle.main.appVersion
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 3) {
          Image(uiImage: appIcon!)
            .resizable()
            .frame(width: 70, height: 70)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
          
          Text("Version \(appVersion)")
            .font(.mukta(.regular, size: 15))
            .foregroundColor(.darkGrey)
        }
        .padding(.top, 20)
        
        VStack {
          HStack {
            EXSettingsCell(category: $selectedCategory, type: .categories, action: {navigateTo()})
            EXSettingsCell(category: $selectedCategory, type: .reminders, action: {navigateTo()})
          }
          HStack {
            EXSettingsCell(category: $selectedCategory, type: .exportData, action: {navigateTo()})
            EXSettingsCell(category: $selectedCategory, type: .resetAccount, action: {navigateTo()})
          }
          HStack {
            EXSettingsCell(category: $selectedCategory, type: .contact, action: {navigateTo()})
          }
        }
        .applyMargins()
        .padding(.top, 16)
      }
      .applyBounce()
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
            .font(.mukta(.medium, size: 17))
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
    
    let title = "Tools"
    
    let backIcon = Source.Images.Navigation.back
    
  }
}

extension SettingsView {
  private func navigateTo() {
    switch selectedCategory {
    case "Categories": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(CategoriesSettingsView()))
    case "Reminders": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RemindersSettingsView()))
    case "Export Data": print("Navigation error")
    case "Reset Data": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(EraseDataSettingsView()))
    case "Contact": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(ContactSettingsView()))
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
