//
//  RemindersSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/23/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView
import RealmSwift

struct RemindersSettingsView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var reminderOn = UserDefaults.standard.bool(forKey: "notificationsEnabled")
  let notificationManager: NotificationManager = NotificationManager.shared
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Realm
  @Environment(\.realm) var realm
  
  // MARK: Presentation
  @State private var showToast = false
  @State private var showLoader = false
  @State private var showDangerSheet = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(alignment: .leading, spacing: 15) {
            Text("General")
              .foregroundColor(.darkGrey)
              .font(.system(.footnote, weight: .regular))
            EXToggleCard(config: (Source.Strings.ToggleType.notifications.title, 
                                  Source.Strings.ToggleType.notifications.text),
                         isOn: $reminderOn)
              .onChange(of: reminderOn, perform: { value in
                if value {
                  print("Notifications granted!")
                  DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    UserDefaults.standard.setValue(true, forKey: "notificationsEnabled")
                    UserDefaults.standard.synchronize()
                  }
                } else {
                  print("Notifications not granted!")
                  DispatchQueue.main.async {
                    UIApplication.shared.unregisterForRemoteNotifications()
                    UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
                    UserDefaults.standard.synchronize()
                  }
                }
              })
          }
          
          VStack(alignment: .leading, spacing: 15) {
            Text("In-app notifications")
              .foregroundColor(.darkGrey)
              .font(.system(.footnote, weight: .regular))
            EXDialog(config: (Source.Strings.DialogType.deleteReminders.title, 
                              Source.Strings.DialogType.deleteReminders.text)) {
              Button(action: {
                showDangerSheet.toggle()
              }, label: {
                Text("Delete all reminders")
                  .font(.system(.subheadline, weight: .semibold))
              })
              .buttonStyle(EXPrimaryButtonStyle(showLoader: $showLoader))
            }
          }
        }
        .padding(.top, 20)
      }
      .scrollBounceBehavior(.basedOnSize)
      .applyMargins()
      .sheet(isPresented: $showDangerSheet, content: {
        dangerSheet()
          .fixedSize(horizontal: false, vertical: true)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
      })
      .popup(isPresented: $showToast, view: {
        EXToast(type: .constant(.remindersDeleted))
      }, customize: {
        $0
          .isOpaque(true)
          .type(.floater())
          .position(.top)
          .autohideIn(1.5)
      })
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

struct RemindersSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    RemindersSettingsView()
      .environment(\.realmConfiguration, RealmMigrator.configuration)
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

extension RemindersSettingsView {
  @ViewBuilder
  func dangerSheet() -> some View {
    ViewThatFits(in: .vertical) {
      VStack(spacing: 30) {
        VStack(alignment: .leading, spacing: 3, content: {
          Text("Are you sure?")
            .font(.title2Bold)
          Text("Proceeding with this action will delete all pending notifications about upcoming payments. This action is irreversible.")
            .font(.headlineRegular)
            .foregroundColor(.darkGrey)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        HStack {
          Button(action: {
            showDangerSheet.toggle()
          }, label: {
            Text("Leave all")
              .font(.headlineSemibold)
          })
          .buttonStyle(EXSecondaryPrimaryButtonStyle(showLoader: .constant(false)))
          Button(action: {
            showDangerSheet.toggle()
            deleteReminders()
          }, label: {
            Text("Delete reminders")
              .font(.headlineSemibold)
          })
          .buttonStyle(EXDestructiveButtonStyle(showLoader: $showLoader))
        }
      }
      .padding(16)
    }
    .background(Color.white)
  }
}

// MARK: - Realm Functions
extension RemindersSettingsView {
  func deleteReminders() {
    showLoader.toggle()
    let payments = realm.objects(RecurringTransaction.self)
    
    try? realm.write {
      payments.setValue(false, forKey: "isReminder")
    }
    notificationManager.deleteNotifications()
    AnalyticsManager.shared.log(.removeReminders)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      showLoader.toggle()
      showToast.toggle()
    }
  }
}
