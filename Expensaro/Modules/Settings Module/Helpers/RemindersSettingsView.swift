//
//  RemindersSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/23/23.
//

import SwiftUI
import ExpensaroUIKit

struct RemindersSettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var reminderOn = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          EXToggleCard(type: .reminders, isOn: $reminderOn)
          EXToggleCard(type: .reminders, isOn: $reminderOn)
        }
        .padding(.top, 20)
      }
      .scrollDisabled(true)
      .applyMargins()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
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

struct RemindersSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    RemindersSettingsView()
  }
}

// MARK: - Appearance
extension RemindersSettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Reminders"
    
    let backIcon = Source.Images.Navigation.back
  }
}
