//
//  EraseDataSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/26/23.
//

import SwiftUI
import ExpensaroUIKit

struct EraseDataSettingsView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  var body: some View {
    NavigationView {
      ScrollView {
        EXDialog(type: .eraseData, bottomView: {
          Button(action: {}, label: {
            Text("Reset account")
              .font(.mukta(.semibold, size: 15))
          })
          .buttonStyle(EXDestructiveButtonStyle(showLoader: .constant(false)))
          .padding(.top, 15)
        })
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
