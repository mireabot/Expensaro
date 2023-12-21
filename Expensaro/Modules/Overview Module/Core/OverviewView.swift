//
//  OverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit

struct OverviewView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // MARK: Presentation
  @State private var showSpendingsInfoSheet = false
  @State private var showTopCategoryInfoSheet = false
  var body: some View {
    NavigationView {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 16) {
          EXInfoCardWithButton(type: .topCategory, icon: Source.Images.InfoCardIcon.topCategory, buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showTopCategoryInfoSheet.toggle()})
          EXInfoCardWithButton(type: .monthToMonth, icon: Source.Images.InfoCardIcon.month2month, buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showSpendingsInfoSheet.toggle()})
          EXInfoCard(type: .overviewUpdates)
        }
        .padding(.top, 16)
      }
      .sheet(isPresented: $showTopCategoryInfoSheet, content: {
        EXBottomInfoView(type: .topCategory, action: {
          DispatchQueue.main.async {
            showTopCategoryInfoSheet.toggle()
          }
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TopCategoryOverviewView()))
        }, bottomView: {
          EXTopCategoryView()
        })
        .applyMargins()
        .presentationDetents([.fraction(0.4)])
      })
      .sheet(isPresented: $showSpendingsInfoSheet, content: {
        EXBottomInfoView(type: .spendings, action: {}, bottomView: {
          EmptyView()
        })
        .applyMargins()
        .presentationDetents([.fraction(0.4)])
      })
      .applyMargins()
      .scrollDisabled(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text(Appearance.shared.title)
            .font(.system(.title2, weight: .semibold))
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
