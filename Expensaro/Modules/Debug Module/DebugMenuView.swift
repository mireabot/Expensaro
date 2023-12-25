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
  let notificationManager: NotificationManager = NotificationManager.shared
  
  // MARK: - Realm
  @ObservedResults(Budget.self) var budgets
  @ObservedResults(Transaction.self) var transactions
  
  @State private var notifications : [String] = []
  var body: some View {
    NavigationView {
      VStack {
        List {
          Section(header: Text("Budgets")) {
            ForEach(budgets) { budget in
              HStack {
                VStack(alignment: .leading, spacing: 3) {
                  Text("Current amount $\(budget.amount.withDecimals)")
                  Text("Initial amount $\(budget.initialAmount.withDecimals)")
                }
                Spacer()
                Text("\(Source.Functions.showString(from: budget.dateCreated))")
              }
            }
          }
          
          Section(header: Text("Pending notifications")) {
            ForEach(notifications, id: \.self) { data in
              Text(data)
            }
          }
          
          Section(header: Text("Spendings")) {
            ForEach(Array(groupTransactionsByMonth(transactions: transactions.toArray())), id: \.0) { month, transactions in
              Text("Total for \(month): \(transactions.reduce(0) { $0 + $1.amount })")
            }
          }
        }
      }
      .onFirstAppear {
        notificationManager.printNotifications { result in
          notifications = result
        }
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
        
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            writeCategories()
          } label: {
            Text("Update categories")
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
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
  
  func writeCategories() {
    let loadedCategories: [Category] = [
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.subscriptions, name: "Subscription", tag: .base, section: .entertainment),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.entertainment, name: "Entertainment", tag: .base, section: .entertainment),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.hobby, name: "Hobby", tag: .base, section: .entertainment),
      
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.goingOut, name: "Going out", tag: .base, section: .food),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.groceries, name: "Groceries", tag: .base, section: .food),
      
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.bills, name: "Bills", tag: .base, section: .housing),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.utilities, name: "Utilities", tag: .base, section: .housing),
      
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.publicTransport, name: "Public transport", tag: .base, section: .transportation),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.car, name: "Car", tag: .base, section: .transportation),
      
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.education, name: "Education", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.travel, name: "Travel", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.shopping, name: "Shopping", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.delivery, name: "Delivery", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.gaming, name: "Gaming", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.animals, name: "Animals", tag: .base, section: .lifestyle),
      
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.clothes, name: "Clothes", tag: .base, section: .other),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.other, name: "Other", tag: .base, section: .other),
      Source.Realm.createCategory(icon: Source.Strings.Categories.Images.medicine, name: "Healthcare", tag: .base, section: .other),
    ]
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(loadedCategories)
    })
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
