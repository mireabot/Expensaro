//
//  DailyTransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/26/24.
//

import SwiftUI
import PopupView
import ExpensaroUIKit
import Charts

struct DailyTransactionInsightsView: View {
  @State private var showAnalyticsDemo = false
  @StateObject var manager = DailyTransactionsAnalyticsManager()
  
  @State private var showFeedback = false
  var body: some View {
    Group {
      if manager.isLocked {
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
                  showFeedback.toggle()
                }
              } label: {
                Image(systemName: "ellipsis")
                  .foregroundStyle(.black)
              }
            }
            Chart(manager.groupedTransactions) { chartData in
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
    .fullScreenCover(isPresented: $showFeedback, content: {
      ContactSettingsView(topic: "Daily Transactions Insights", isCalled: true)
    })
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
