//
//  SettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit

struct SettingsView: View {
  var body: some View {
    NavigationView {
      ScrollView {
        
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            
          } label: {
            Source.Images.Navigation.back
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(.black)
          }

        }
        ToolbarItem(placement: .principal) {
          Text("Settings")
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
