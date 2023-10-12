//
//  InitialPermissionView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct InitialPermissionView: View {
  @Environment(\.realm) var realm
  
  @State private var notificationsSelected = false
  @State private var analyticsSelected = false
  @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        Text("Permissions")
          .font(.mukta(.semibold, size: 20))
        Text("Before we start - we need a few things to set up")
          .font(.mukta(.regular, size: 15))
          .foregroundColor(.darkGrey)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top)
      
      VStack(spacing: 20) {
        EXToggleCard(type: .notifications, isOn: $notificationsSelected)
      }
      .padding(.top, 30)
    }
    .interactiveDismissDisabled(true)
    .safeAreaInset(edge: .bottom, content: {
      Button {
        try? realm.write {
          realm.add(DefaultCategories.defaultCategories)
        }
        isUserLoggedIn = true
      } label: {
        Text("Finish")
          .font(.mukta(.semibold, size: 17))
      }
      .buttonStyle(PrimaryButtonStyle(showLoader: .constant(false)))
      .padding(.bottom, 20)

    })
    .applyMargins()
    .scrollDisabled(true)
  }
}

struct InitialPermissionView_Previews: PreviewProvider {
  static var previews: some View {
    InitialPermissionView()
  }
}
