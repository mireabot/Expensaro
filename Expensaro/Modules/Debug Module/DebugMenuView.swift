//
//  DebugMenuView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/10/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct DebugMenuView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // MARK: - Realm
  @ObservedResults(Budget.self) var budgets
  @ObservedResults(Transaction.self) var transactions
  
  @State private var notifications: [UNNotificationRequest] = []
  var body: some View {
    NavigationView {
      List(content: {
        Section(header: Text("Budgets")) {
          ForEach(budgets) { budget in
            HStack {
              Text("$\(budget.amount.withDecimals)")
              Spacer()
              Text("\(Source.Functions.showString(from: budget.dateCreated))")
            }
          }
        }
        
        Section(header: Text("Pending notifications")) {
          ForEach(notifications, id: \.identifier) { notification in
            Text(notification.content.title)
          }
        }
        
        Section(header: Text("Spendings")) {
          ForEach(Array(groupTransactionsByMonth(transactions: transactions.toArray())), id: \.0) { month, transactions in
            Text("Total for \(month): \(transactions.reduce(0) { $0 + $1.amount })")
          }
        }
      })
      .onFirstAppear {
        getPendingNotifications()
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.white, for: .bottomBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
        }
      }
    }
  }
  func getPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
      DispatchQueue.main.async {
        self.notifications = requests
      }
    }
  }
  
  func groupTransactionsByMonth(transactions: [Transaction]) -> [(String, [Transaction])] {
    let groupedByMonth = Dictionary(grouping: transactions) { transaction in
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMMM yyyy"
      return dateFormatter.string(from: transaction.date)
    }
    return groupedByMonth.sorted { $0.0 < $1.0 }
  }
}

#Preview {
  DebugMenuView()
    .environment(\.realmConfiguration, RealmMigrator.configuration)
}

// MARK: - Appearance
extension DebugMenuView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Debug Menu"
    
    let backIcon = Source.Images.Navigation.back
    
  }
}

extension Results {
  func toArray() -> [Element] {
    return self.map { $0 }
  }
}
