//
//  EraseDataSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/26/23.
//

import SwiftUI
import ExpensaroUIKit

struct EraseDataSettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @State private var eraseTransactions = true
  @State private var deleteAccount = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Text("Reset your account")
            .font(.mukta(.semibold, size: 24))
          Text("Get rid of the past and start fresh")
            .font(.mukta(.regular, size: 17))
            .foregroundColor(.darkGrey)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        selectorView()
        .padding(.top, 20)
      }
      .safeAreaInset(edge: .bottom, content: {
        Button(action: {}) {
          Text("Reset data")
            .font(.mukta(.semibold, size: 17))
        }
        .foregroundColor(.white)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.red)
        .cornerRadius(8)
        .padding(.bottom, 20)
      })
      .scrollDisabled(true)
      .applyMargins()
      .onChange(of: eraseTransactions, perform: { newValue in
        deleteAccount = !newValue
      })
      .onChange(of: deleteAccount, perform: { newValue in
        eraseTransactions = !newValue
      })
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


extension EraseDataSettingsView {
  @ViewBuilder
  func selectorView() -> some View {
    VStack(alignment: .center, spacing: 20) {
      EXCheckmarkSelector(type: .eraseData, isSelected: $eraseTransactions)
      EXCheckmarkSelector(type: .deleteAccount, isSelected: $deleteAccount)
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
    .shadowXS()
  }
}
