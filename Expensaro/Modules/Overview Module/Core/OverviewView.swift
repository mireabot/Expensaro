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
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Variables
  @State private var sheetHeight: CGFloat = .zero
  @StateObject var topCategoryService = TopCategoryManager.init()
  @StateObject var monthRecapService = MonthRecapService.init()
  
  // MARK: Presentation
  @State private var showSpendingsInfoSheet = false
  @State private var showTopCategoryInfoSheet = false
  var body: some View {
    NavigationView {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 16) {
          topCategorySection()
          monthRecapSection()
          EXInfoCard(type: .overviewUpdates)
        }
        .padding(.top, 16)
      }
      .onFirstAppear {
        topCategoryService.groupAndFindMaxAmountCategory()
      }
      .sheet(isPresented: $showTopCategoryInfoSheet, content: {
        EXBottomInfoView(type: .topCategory, action: {
          DispatchQueue.main.async {
            showTopCategoryInfoSheet.toggle()
          }
          AnalyticsManager.shared.log(.openTopCategoryPreview)
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TopCategoryOverviewView(service: topCategoryService)))
        }, bottomView: {
          EXOverviewCard(header: "Top Category", title: "Electronics", icon: Source.Images.Navigation.redirect, subHeader: "You have spent \(Double(2000).formattedAsCurrencySolid(with: currencySign)) on this category")
        })
        .applyMargins()
        .presentationDetents([.fraction(0.4)])
      })
      .sheet(isPresented: $showSpendingsInfoSheet, content: {
        ViewThatFits(in: .vertical, content: {
          EXBottomInfoView(type: .spendings, action: {
            DispatchQueue.main.async {
              showSpendingsInfoSheet.toggle()
            }
            AnalyticsManager.shared.log(.openMonthRecapPreview)
            router.pushTo(view: EXNavigationViewBuilder.builder.makeView(MonthRecapOverviewView(service: monthRecapService)))
          }, bottomView: {
            EXOverviewCard(header: "Month recap", title: Source.Functions.currentMonth(date: Source.Functions.getPastMonthDates().0), icon: Source.Images.Navigation.redirect, subHeader: "Check your financial activity breakdown")
          })
          .applyMargins()
        })
        .fixedSize(horizontal: false, vertical: true)
        .modifier(GetHeightModifier(height: $sheetHeight))
        .presentationDetents([.height(sheetHeight)])
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

extension OverviewView {
  @ViewBuilder
  func topCategorySection() -> some View {
    if topCategoryService.transactions.count >= 15 {
      Button(action: {
        router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TopCategoryOverviewView(service: topCategoryService)))
        AnalyticsManager.shared.log(.openTopCategory)
      }, label: {
        EXOverviewCard(header: "Top Category", title: topCategoryService.topCategory.0, icon: Source.Images.Navigation.redirect, subHeader: "You have spent \(topCategoryService.topCategory.1.formattedAsCurrencySolid(with: currencySign)) on this category")
      })
      .buttonStyle(EXPlainButtonStyle())
    } else {
      EXInfoCardWithButton(type: .topCategory, icon: Source.Images.InfoCardIcon.topCategory, buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showTopCategoryInfoSheet.toggle()})
    }
  }
  
  @ViewBuilder
  func monthRecapSection() -> some View {
    if monthRecapService.isLocked {
      EXInfoCardWithButton(type: .monthToMonth, icon: Source.Images.InfoCardIcon.month2month, buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showSpendingsInfoSheet.toggle()})
    }
    else {
      Button(action: {
        router.pushTo(view: EXNavigationViewBuilder.builder.makeView(MonthRecapOverviewView(service: monthRecapService)))
        AnalyticsManager.shared.log(.openMonthRecap)
      }, label: {
        EXOverviewCard(header: "Month recap", title: monthRecapService.recapMonth, icon: Source.Images.Navigation.redirect, subHeader: "Check your financial activity breakdown")
      })
      .buttonStyle(EXPlainButtonStyle())
    }
  }
}
