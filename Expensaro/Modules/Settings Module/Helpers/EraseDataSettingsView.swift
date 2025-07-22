//
//  EraseDataSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/26/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct EraseDataSettingsView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
  
  // MARK: Variables
  @State private var sheetHeight: CGFloat = .zero
  @State private var showSheet = false
  @State private var showLoader = false
  var body: some View {
    NavigationView {
      ScrollView {
        EXDialog(config: (Source.Strings.DialogType.eraseData.title,
                          Source.Strings.DialogType.eraseData.text),
                 bottomView: {
          Button(action: {
            showSheet.toggle()
          }, label: {
            Text("Reset account")
              .font(.system(.subheadline, weight: .semibold))
          })
          .buttonStyle(EXDestructiveButtonStyle(showLoader: .constant(false)))
        })
        .padding(.top, 20)
        .applyMargins()
      }
      .scrollBounceBehavior(.basedOnSize)
      .sheet(isPresented: $showSheet, content: {
        dangerSheet()
          .fixedSize(horizontal: false, vertical: true)
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
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

struct EraseDataSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    EraseDataSettingsView()
  }
}

// MARK: - Appearance
extension EraseDataSettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Reset data"
    
    let backIcon = Source.Images.Navigation.back
  }
}

extension EraseDataSettingsView {
  @ViewBuilder
  func dangerSheet() -> some View {
    ViewThatFits(in: .vertical) {
      VStack(spacing: 30) {
        VStack(alignment: .leading, spacing: 3, content: {
          Text("Are you sure?")
            .font(.title2Bold)
          Text("Proceeding with this action will permanently erase all the data you have created. This action is irreversible.")
            .font(.headlineRegular)
            .foregroundColor(.darkGrey)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        HStack {
          Button(action: {
            showSheet.toggle()
          }, label: {
            Text("Leave all")
              .font(.headlineSemibold)
          })
          .buttonStyle(EXSecondaryPrimaryButtonStyle(showLoader: .constant(false)))
          Button(action: {
            showLoader.toggle()
            deleteAllData()
          }, label: {
            Text("Delete account")
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
extension EraseDataSettingsView {
  func deleteAllData() {
    AnalyticsManager.shared.log(.deleteAccount)
    let realm = try! Realm()
    try! realm.write {
      realm.deleteAll()
    }
    showLoader = false
    showSheet.toggle()
    DispatchQueue.main.async {
      UIApplication.shared.unregisterForRemoteNotifications()
      UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
      UserDefaults.standard.synchronize()
      withAnimation {
        isUserLoggedIn = false
      }
    }
  }
}
