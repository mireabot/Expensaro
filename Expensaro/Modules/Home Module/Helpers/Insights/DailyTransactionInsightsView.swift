//
//  DailyTransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/26/24.
//

import SwiftUI
import PopupView
import ExpensaroUIKit

struct DailyTransactionInsightsView: View {
  @State private var showAnalyticsDemo = false
  var body: some View {
    Group {
      Button(action: {
        showAnalyticsDemo.toggle()
      }, label: {
        EXEmptyStateView(type: .noDailyTransactionsInsights, isActive: true)
      })
      .buttonStyle(EXPlainButtonStyle())
    }
    .popup(isPresented: $showAnalyticsDemo) {
      EXBottomInfoView(config: (Source.Strings.BottomPreviewType.transactions.title,
                                Source.Strings.BottomPreviewType.transactions.text,
                                Source.Strings.BottomPreviewType.transactions.isButton,
                                Source.Strings.BottomPreviewType.transactions.buttonText),
                       action: {
        showAnalyticsDemo.toggle()
      },
                       bottomView: {
        Source.Images.Previews.dailyTransactionsInsightsPreview
          .frame(maxWidth: .infinity)
          .background(Color.backgroundGrey)
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
  }
}

#Preview {
  DailyTransactionInsightsView()
}
