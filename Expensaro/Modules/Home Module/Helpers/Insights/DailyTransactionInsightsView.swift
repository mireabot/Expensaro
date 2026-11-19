//
//  DailyTransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/26/24.
//

import SwiftUI
import Dependencies
import PopupView
import ExpensaroUIKit
import Charts
import SwiftData

struct DailyTransactionInsightsView: View {
  @Dependency(\.router) private var router
  @State private var showAnalyticsDemo = false
  @Query(Transaction.dailyThisWeek) private var dailyTransactions: [Transaction]
  
  var body: some View {
    Group {
      // At least 4 daily transactions this week before the chart unlocks
      if dailyTransactions.count < 4 {
        Button(action: {
          showAnalyticsDemo.toggle()
        }, label: {
          EXEmptyStateView(type: .noDailyTransactionsInsights, isActive: true)
        })
        .buttonStyle(EXPlainButtonStyle())
      } else {
        EXBaseCard {
          VStack(alignment: .leading, spacing: 10, content: {
            HStack(alignment: .firstTextBaseline) {
              VStack(alignment: .leading, spacing: 3, content: {
                Text("Daily Transactions Insight")
                  .font(.title3Bold)
                Text("Your spending trend for this week")
                  .font(.footnoteRegular)
                  .foregroundStyle(Color.darkGrey)
              })
              Spacer()
              Menu {
                Button("Provide feedback") {
                  router.presentFullScreenCover(.feedback(topic: "Daily Transactions Insights"))
                }
              } label: {
                Image(systemName: "ellipsis")
                  .foregroundStyle(.black)
              }
            }
            Chart(dailyTransactions.weekdayTotals) { chartData in
              BarMark(x: .value("Day", chartData.weekday), y: .value("$", chartData.totalAmount))
                .foregroundStyle(Color.primaryGreen)
                .cornerRadius(5)
                .annotation(position: .top, alignment: .center, spacing: 5) {
                  Text("$\(String(format: "%.2f", chartData.totalAmount))")
                    .font(.footnoteMedium)
                    .foregroundStyle(Color.darkGrey)
                }
                .annotation(position: .bottom, alignment: .center, spacing: 5) {
                  Text(chartData.weekday)
                    .font(.footnoteRegular)
                    .foregroundStyle(.black)
                }
            }
            .frame(height: 200)
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
          })
        }
      }
    }
    .popup(isPresented: $showAnalyticsDemo) {
      EXBottomInfoView(config: (Source.Strings.BottomPreviewType.dailyTransactions.title,
                                Source.Strings.BottomPreviewType.dailyTransactions.text,
                                Source.Strings.BottomPreviewType.dailyTransactions.isButton,
                                Source.Strings.BottomPreviewType.dailyTransactions.buttonText),
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
    .modelContainer(AppModelStore.preview)
}
