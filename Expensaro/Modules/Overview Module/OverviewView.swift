//
//  OverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit

struct OverviewView: View {
  var body: some View {
    NavigationView {
      ScrollView(.vertical, showsIndicators: false) {
        
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("Overview")
            .font(.mukta(.medium, size: 24))
            .padding(.bottom, 20)
        }
      }
    }
  }
}

struct OverviewView_Previews: PreviewProvider {
  static var previews: some View {
    OverviewView()
  }
}
