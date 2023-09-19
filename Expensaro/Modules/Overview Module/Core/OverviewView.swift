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
        VStack(spacing: 20) {
          EXInfoCardWithButton(type: .monthToMonth, icon: Source.Images.InfoCardIcon.month2month, buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {})
          EXInfoCardWithButton(type: .topCategory, icon: Source.Images.InfoCardIcon.topCategory, buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {})
          EXInfoCard(type: .overviewUpdates)
        }
        .padding(.top, 16)
      }
      .applyMargins()
      .scrollDisabled(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 24))
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

// MARK: - Apperance
extension OverviewView {
  struct Appearance {
    static let shared = Appearance()
    let title = "Overview"
  }
}
