//
//  OverviewView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import PopupView
import SwiftData

struct OverviewView: View {
  // MARK: Essential
  @Dependency(\.router) private var router
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: Variables
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Storage
  @Query(Transaction.thisMonth) private var transactions: [Transaction]
  @Query(Budget.thisMonth) private var budget: [Budget]
  @Query(Transaction.lastMonth) private var lastMonthTransactions: [Transaction]
  @Query(Budget.lastMonth) private var lastMonthBudget: [Budget]
  @Query(GoalTransaction.lastMonth) private var lastMonthGoalTransactions: [GoalTransaction]
  
  // MARK: Presentation
  @State private var showSpendingsInfoSheet = false
  @State private var showTopCategoryInfoSheet = false
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 16) {
        topCategorySection()
        monthRecapSection()
        EXInfoCard(config: (Source.Strings.InfoCardType.overviewUpdates.title,
                            Source.Strings.InfoCardType.overviewUpdates.text))
      }
      .padding(.top, 16)
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
        router.navigate(to: .topCategoryOverview(topCategory))
      }, bottomView: {
        Source.Images.Previews.topCategoryPreview
          .frame(maxWidth: .infinity)
          .background(Color.white)
          .cornerRadius(10)
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
        router.navigate(to: .monthRecap(monthRecap))
      }, bottomView: {
        Source.Images.Previews.monthRecapPreview
          .frame(maxWidth: .infinity)
          .background(Color.white)
          .cornerRadius(10)
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
    .rootNavigationTitle(Appearance.shared.title)
  }
}

struct OverviewView_Previews: PreviewProvider {
  static var previews: some View {
    OverviewView()
      .modelContainer(AppModelStore.preview)
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
  var topCategory: TopCategorySummary {
    TopCategorySummary(transactions: transactions, budget: budget.first)
  }
  
  var monthRecap: MonthRecap {
    MonthRecap(budgets: lastMonthBudget, transactions: lastMonthTransactions, goalTransactions: lastMonthGoalTransactions)
  }
  
  @ViewBuilder
  func topCategorySection() -> some View {
    let topCategory = self.topCategory
    if !topCategory.isLocked {
      Button(action: {
        router.navigate(to: .topCategoryOverview(topCategory))
      }, label: {
        EXOverviewCard(header: "Top Category", title: topCategory.topCategory.0, icon: Source.Images.Navigation.redirect, subHeader: "You have spent \(topCategory.topCategory.1.formattedAsCurrencySolid(with: currencySign)) on this category")
      })
      .buttonStyle(EXPlainButtonStyle())
    } else {
      EXInfoCardWithButton(config: (Source.Strings.InfoCardType.topCategory.title, Source.Strings.InfoCardType.topCategory.text), icon: .image(Source.Images.InfoCardIcon.topCategory), buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showTopCategoryInfoSheet.toggle()})
    }
  }
  
  @ViewBuilder
  func monthRecapSection() -> some View {
    let monthRecap = self.monthRecap
    if monthRecap.isLocked {
      EXInfoCardWithButton(config: (Source.Strings.InfoCardType.monthToMonth.title, Source.Strings.InfoCardType.monthToMonth.text), icon: .image(Source.Images.InfoCardIcon.month2month), buttonIcon: Source.Images.ButtonIcons.how, buttonAction: {showSpendingsInfoSheet.toggle()})
    }
    else {
      Button(action: {
        router.navigate(to: .monthRecap(monthRecap))
      }, label: {
        EXOverviewCard(header: "Month recap", title: monthRecap.recapMonth, icon: Source.Images.Navigation.redirect, subHeader: "Check your financial activity breakdown")
      })
      .buttonStyle(EXPlainButtonStyle())
    }
  }
}
