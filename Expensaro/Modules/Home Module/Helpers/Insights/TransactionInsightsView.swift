//
//  TransactionInsightsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/27/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct TransactionInsightsView: View {
  @State private var showAnalyticsDemo = false
  @ObservedObject var service : SelectedCategoryAnalyticsManager
  @AppStorage("currencySign") private var currencySign = "$"
  var body: some View {
    Group {
      if service.isLocked {
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
            HStack {
              VStack(alignment: .leading, spacing: 0) {
                Text("\(currencySign)\(service.averageSpent.clean)")
                  .font(.title3Bold)
                  .foregroundColor(.black)
                Text("Avg. transaction amount")
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
              }
              
              Spacer()
              
              Source.Images.InfoCardIcon.month2month
                .foregroundColor(.primaryGreen)
            }
            VStack(alignment: .leading, spacing: 5) {
              Text("Top 3 transactions in category")
                .font(.footnoteMedium)
                .foregroundColor(.black)
              VStack(spacing: 10) {
                ForEach(service.transactionsList.prefix(3), id: \.name) { transaction in
                  HStack(alignment: .center) {
                    Text(transaction.name)
                      .font(.footnoteRegular)
                      .foregroundColor(.darkGrey)
                      
                    Spacer()
                    
                    Text("\(currencySign)\(transaction.amount.clean)")
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
    .onFirstAppear {
      service.calculateAverage()
    }
    .sheet(isPresented: $showAnalyticsDemo, content: {
      EXBottomInfoView(type: .transactions, action: {}, bottomView: {
        demoView()
      })
      .onFirstAppear {
        service.calculateAverageDemo()
      }
      .applyMargins()
      .presentationDetents([.fraction(0.45)])
    })
  }
}

#Preview {
  TransactionInsightsView(service: .init(selectedCategory: "Shopping")).applyMargins()
}

extension TransactionInsightsView {
  @ViewBuilder
  func demoView() -> some View {
    EXBaseCard {
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Text("\(currencySign)\(service.averageSpent.clean)")
              .font(.title3Bold)
              .foregroundColor(.black)
            Text("Avg. transaction amount")
              .font(.footnoteRegular)
              .foregroundColor(.darkGrey)
          }
          
          Spacer()
          
          Source.Images.InfoCardIcon.month2month
            .foregroundColor(.primaryGreen)
        }
        VStack(alignment: .leading, spacing: 5) {
          Text("Top 3 transactions in category")
            .font(.footnoteMedium)
            .foregroundColor(.black)
          VStack(spacing: 10) {
            ForEach(service.demoTransactions.prefix(3), id: \.amount) { transaction in
              HStack(alignment: .center) {
                Text(transaction.name)
                  .font(.footnoteRegular)
                  .foregroundColor(.darkGrey)
                  
                Spacer()
                
                Text("\(currencySign)\(transaction.amount.clean)")
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
