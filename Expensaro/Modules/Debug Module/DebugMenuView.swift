//
//  DebugMenuView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/10/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import UserNotifications

struct DebugMenuView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  let notificationManager: NotificationManager = NotificationManager.shared
  @AppStorage("currencySign") private var currencySign = "USD"
  
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
          
          Section {
            Button {
              writeCategories()
            } label: {
              Text("Update categories")
            }
            Button {
              createDemoProfile()
            } label: {
              Text("Create Demo Profile")
            }
            Button {
              testNotification()
            } label: {
              Text("Test Notification")
            }
            Button {
              loadTransactions()
            } label: {
              Text("Load Transactions")
            }
            Button {
              addSameCategoryTransactions()
            } label: {
              Text("Add same category transactions")
            }
          } header: {
            Text("Actions")
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
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
      }
    }
  }
  private func groupTransactionsByMonth(transactions: [Transaction]) -> [(String, [Transaction])] {
    let groupedByMonth = Dictionary(grouping: transactions) { transaction in
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMMM yyyy"
      return dateFormatter.string(from: transaction.date)
    }
    return groupedByMonth.sorted { $0.0 < $1.0 }
  }
  
  private func writeCategories() {
    let loadedCategories: [Category] = [
      Source.Realm.createCategory(icon: "🔄", name: "Subscription", tag: .base, section: .entertainment),
      Source.Realm.createCategory(icon: "🎫", name: "Entertainment", tag: .base, section: .entertainment),
      Source.Realm.createCategory(icon: "🎨", name: "Hobby", tag: .base, section: .entertainment),
      
      Source.Realm.createCategory(icon: "🥡", name: "Going out", tag: .base, section: .food),
      Source.Realm.createCategory(icon: "🛒", name: "Groceries", tag: .base, section: .food),
      
      Source.Realm.createCategory(icon: "🧾", name: "Bills", tag: .base, section: .housing),
      Source.Realm.createCategory(icon: "🏠", name: "Utilities", tag: .base, section: .housing),
      
      Source.Realm.createCategory(icon: "🚈", name: "Public transport", tag: .base, section: .transportation),
      Source.Realm.createCategory(icon: "🚘", name: "Car", tag: .base, section: .transportation),
      
      Source.Realm.createCategory(icon: "📚", name: "Education", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🛩️", name: "Travel", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🛍️", name: "Shopping", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "📦", name: "Delivery", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🎮", name: "Gaming", tag: .base, section: .lifestyle),
      Source.Realm.createCategory(icon: "🐾", name: "Animals", tag: .base, section: .lifestyle),
      
      Source.Realm.createCategory(icon: "👕", name: "Clothes", tag: .base, section: .other),
      Source.Realm.createCategory(icon: "📔", name: "Other", tag: .base, section: .other),
      Source.Realm.createCategory(icon: "🩹", name: "Healthcare", tag: .base, section: .other),
    ]
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(loadedCategories)
    })
  }
  
  private func createDemoProfile() {
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(Source.DefaultData.sampleBudget)
      realm.add(Source.DefaultData.samplePreviousBudget)
      realm.add(Source.DefaultData.sampleTransactions)
      realm.add(Source.DefaultData.sampleRecurringPayments)
      realm.add(Source.DefaultData.sampleGoals)
    })
  }
  
  private func addSameCategoryTransactions() {
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(Source.DefaultData.sampleTransactionsWithCategory)
    })
  }
  
  private func loadTransactions() {
    let realm = try! Realm()
    
    try? realm.write({
      realm.add(Source.DefaultData.loadedTransactions)
    })
  }
  
  private func testNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Netflix is due tomorrow"
    content.body = "Your \(Double(6.99).formattedAsCurrencySolid(with: currencySign)) Netflix payment is due tomorrow. Don't forget to renew or cancel as needed!"
    content.sound = UNNotificationSound.default
    
    // show this notification five seconds from now
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    // choose a random identifier
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    // add our notification request
    UNUserNotificationCenter.current().add(request)
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
