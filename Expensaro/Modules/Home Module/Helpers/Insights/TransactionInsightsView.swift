//
//  TransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/27/23.
//

import SwiftUI
import ExpensaroUIKit
import PopupView
import SwiftData

struct TransactionInsightsView: View {
  @State private var showAnalyticsDemo = false
  @Query private var transactions: [Transaction]
  @AppStorage("currencySign") private var currencySign = "USD"
  
  @State private var showFeedback = false
  
  init(categoryName: String) {
    _transactions = Query(Transaction.inCategoryThisMonth(categoryName))
  }
  
  private var isLocked: Bool {
    transactions.count < 5
  }
  
  var body: some View {
    Group {
      if isLocked {
        Button(action: {
          showAnalyticsDemo.toggle()
        }, label: {
          EXEmptyStateView(type: .noTransactionInsights, isActive: true)
        })
        .padding([.top, .bottom], 5)
        .buttonStyle(EXPlainButtonStyle())
      } else {
        EXBaseCard {
          VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
              VStack(alignment: .leading, spacing: 0) {
                Text("\(transactions.averageAmount.formattedAsCurrency(with: currencySign))")
                  .font(.title3Bold)
                  .foregroundColor(.black)
                Text("Avg. transaction amount")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
              }
              
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
            VStack(alignment: .leading, spacing: 5) {
              Text("Top 3 transactions in category")
                .font(.footnoteMedium)
                .foregroundColor(.black)
              VStack(spacing: 10) {
                ForEach(transactions.prefix(3), id: \.name) { transaction in
                  HStack(alignment: .center) {
                    Text(transaction.name)
                      .font(.footnoteRegular)
                      .foregroundColor(.darkGrey)
                    
                    Spacer()
                    
                    Text("\(transaction.amount.formattedAsCurrencySolid(with: currencySign))")
                      .font(.footnoteMedium)
                      .foregroundColor(.primaryGreen)
                  }
                }
              }
              .padding(.top, 3)
            }
            .padding(10)
            .background(.white)
            .cornerRadius(8)
            .padding(.top, 5)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
    .fullScreenCover(isPresented: $showFeedback, content: {
      ContactSettingsView(topic: "Transaction Insights", isCalled: true)
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
        Source.Images.Previews.transactionInsightsPreview
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
  TransactionInsightsView(categoryName: "Shopping").applyMargins()
    .modelContainer(AppModelStore.preview)
}

