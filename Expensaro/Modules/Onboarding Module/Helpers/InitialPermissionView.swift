//
//  InitialPermissionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import UserNotifications

struct InitialPermissionView: View {
  // MARK: Essential
  @Environment(\.realm) var realm
  let notificationManager: NotificationManager = NotificationManager.shared
  
  // MARK: Storage
  @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
  @AppStorage("currencySign") private var currencyStorage = ""
  
  // MARK: Presentation
  @State private var showAnimation = false
  @State private var showSelector = false
  @State private var notificationsSelected = false
  
  // MARK: Variables
  @State private var currencyText = "US Dollar ($)"
  @State private var currencySymbol = "USD"
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text("Permissions")
          .font(.system(.title3, weight: .semibold))
        Text("Before we start - we need a few things to set up")
          .font(.system(.subheadline, weight: .regular))
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 20)
      
      VStack(spacing: 16) {
        EXToggleCard(type: .notifications, isOn: $notificationsSelected)
          .onChange(of: notificationsSelected, perform: { value in
            if value {
              DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                UserDefaults.standard.setValue(true, forKey: "notificationsEnabled")
                UserDefaults.standard.synchronize()
              }
            } else {
              DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
                UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
                UserDefaults.standard.synchronize()
              }
            }
          })
        EXLargeSelector(text: .constant(currencyText), icon: .constant(.imageName("")), header: "Select currency", rightIcon: "swipeDown")
          .onTapGesture {
            showSelector = true
          }
      }
      .padding(.top, 16)
      .sheet(isPresented: $showSelector, content: {
        currencySelector()
          .presentationDetents([.fraction(0.6)])
          .presentationDragIndicator(.visible)
      })
    }
    .interactiveDismissDisabled(true)
    .safeAreaInset(edge: .bottom, content: {
      Button {
        showAnimation.toggle()
        writeCategories()
        currencyStorage = currencySymbol
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          showAnimation.toggle()
          UserDefaults.standard.setValue(UIDevice.current.identifierForVendor?.uuidString, forKey: "DeviceID")
          UserDefaults.standard.synchronize()
          isUserLoggedIn = true
          
        }
      } label: {
        Text("Finish")
          .font(.system(.headline, weight: .semibold))
      }
      .buttonStyle(EXPrimaryButtonStyle(showLoader: $showAnimation))
      .padding(.bottom, 20)
      
    })
    .applyMargins()
    .scrollDisabled(true)
    .onAppear {
      notificationManager.requestAuthorization {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
          notificationsSelected.toggle()
          UserDefaults.standard.setValue(true, forKey: "notificationsEnabled")
          UserDefaults.standard.synchronize()
        }
      } onFail: {
        UserDefaults.standard.setValue(false, forKey: "notificationsEnabled")
        UserDefaults.standard.synchronize()
      }
    }
  }
}

struct InitialPermissionView_Previews: PreviewProvider {
  static var previews: some View {
    InitialPermissionView()
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Realm Functions
extension InitialPermissionView {
  func writeCategories() {
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(Source.DefaultData.loadedCategories)
    })
  }
}

// MARK: - Helper Views
extension InitialPermissionView {
  @ViewBuilder
  func currencySelector() -> some View {
    NavigationView {
      List(Currency.allCurrencies, id: \.symbol) { currency in
        Button {
          currencySymbol = currency.code
          currencyText = "\(currency.name) (\(currency.symbol))"
          showSelector = false
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
              .opacity(currencySymbol == currency.code ? 1 : 0)
          }
          .background(.white)
        }
        .listRowSeparator(.hidden)
        .buttonStyle(EXPlainButtonStyle())
      }
      .listStyle(.plain)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text(Appearance.shared.title)
            .font(.title3Semibold)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showSelector = false
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

// MARK: - Appearance
extension InitialPermissionView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Select currency"
    
    let backIcon = Source.Images.Navigation.close
  }
}
