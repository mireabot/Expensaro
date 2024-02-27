//
//  OverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView

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
          EXInfoCard(config: (Source.Strings.InfoCardType.overviewUpdates.title,
                              Source.Strings.InfoCardType.overviewUpdates.text))
        }
        .padding(.top, 16)
      }
      .onFirstAppear {
        topCategoryService.groupAndFindMaxAmountCategory()
      }
      .popup(isPresented: $showTopCategoryInfoSheet) {
        EXBottomInfoView(config: (Source.Strings.BottomPreviewType.topCategory.title,
                                  Source.Strings.BottomPreviewType.topCategory.text,
                                  Source.Strings.BottomPreviewType.topCategory.isButton,
                                  Source.Strings.BottomPreviewType.topCategory.buttonText),
                         action: {
          DispatchQueue.main.async {
            showTopCategoryInfoSheet.toggle()
          }
          AnalyticsManager.shared.log(.openTopCategoryPreview)
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(TopCategoryOverviewView(service: topCategoryService)))
        }, bottomView: {
          EXOverviewCard(header: "Top Category", title: "Housing", icon: Source.Images.Navigation.redirect, subHeader: "You have spent \(Double(800).formattedAsCurrencySolid(with: currencySign)) on this category")
        })
        .applyMargins()
        .background(.white)
        .cornerRadius(16)
        .applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .position(.bottom)
          .type(.floater(useSafeAreaInset: true))
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
      .popup(isPresented: $showSpendingsInfoSheet) {
        EXBottomInfoView(config: (Source.Strings.BottomPreviewType.spendings.title,
                                  Source.Strings.BottomPreviewType.spendings.text,
                                  Source.Strings.BottomPreviewType.spendings.isButton,
                                  Source.Strings.BottomPreviewType.spendings.buttonText),
                         action: {
          DispatchQueue.main.async {
            showSpendingsInfoSheet.toggle()
          }
          AnalyticsManager.shared.log(.openMonthRecapPreview)
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(MonthRecapOverviewView(service: monthRecapService)))
        }, bottomView: {
          EXOverviewCard(header: "Month recap", title: Source.Functions.currentMonth(date: Source.Functions.getPastMonthDates().0), icon: Source.Images.Navigation.redirect, subHeader: "Check your financial activity breakdown")
        })
        .applyMargins()
        .background(.white)
        .cornerRadius(16)
        .applyMargins()
      } customize: {
        $0
          .animation(.spring())
          .position(.bottom)
          .type(.floater(useSafeAreaInset: true))
          .closeOnTapOutside(false)
          .backgroundColor(.black.opacity(0.3))
          .isOpaque(true)
      }
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
      EXInfoCardWithButton(config: (Source.Strings.InfoCardType.topCategory.title, Source.Strings.InfoCardType.topCategory.text), icon: .image(Source.Images.InfoCardIcon.topCategory), buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showTopCategoryInfoSheet.toggle()})
    }
  }
  
  @ViewBuilder
  func monthRecapSection() -> some View {
    if monthRecapService.isLocked {
      EXInfoCardWithButton(config: (Source.Strings.InfoCardType.monthToMonth.title, Source.Strings.InfoCardType.monthToMonth.text), icon: .image(Source.Images.InfoCardIcon.month2month), buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showSpendingsInfoSheet.toggle()})
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
