//
//  DebugMenuView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/10/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftData
import UserNotifications

struct DebugMenuView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  let notificationManager: NotificationManager = NotificationManager.shared
  @AppStorage("currencySign") private var currencySign = "USD"
  
  // MARK: - Storage
  @Query(Budget.all) private var budgets: [Budget]
  @Query(Transaction.all) private var transactions: [Transaction]
  
  @State private var notifications : [String] = []
  @State private var rowCounts: [(name: String, count: Int)] = []
  @State private var showEraseConfirmation = false
  var body: some View {
    NavigationView {
      VStack {
        List {
          storageSection()
          
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
            ForEach(Array(groupTransactionsByMonth(transactions: transactions)), id: \.0) { month, transactions in
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
      .onAppear {
        refreshCounts()
      }
      .confirmationDialog("Erase all stored data?", isPresented: $showEraseConfirmation, titleVisibility: .visible) {
        Button("Erase all data", role: .destructive) {
          AppModelStore.eraseAllData()
          refreshCounts()
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
    DemoSeeder.seedBaseCategories()
    refreshCounts()
  }
  
  private func createDemoProfile() {
    DemoSeeder.seedDemoProfile()
    refreshCounts()
  }
  
  private func addSameCategoryTransactions() {
    DemoSeeder.seedSameCategoryTransactions()
    refreshCounts()
  }
  
  private func loadTransactions() {
    DemoSeeder.seedLoadedTransactions()
    refreshCounts()
  }
  
  private func refreshCounts() {
    rowCounts = AppModelStore.rowCounts()
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
    .modelContainer(AppModelStore.preview)
}

// MARK: - Appearance
extension DebugMenuView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Debug Menu"
    
    let backIcon = Source.Images.Navigation.back
    
  }
}

// MARK: - Storage check
extension DebugMenuView {
  @ViewBuilder
  func storageSection() -> some View {
    Section {
      LabeledContent("Schema version", value: schemaVersion)
      VStack(alignment: .leading, spacing: 3) {
        Text("Store URL")
        Text(AppModelStore.storeURL?.path() ?? "In memory")
          .font(.caption)
          .foregroundColor(.darkGrey)
          .textSelection(.enabled)
      }
      ForEach(rowCounts, id: \.name) { row in
        LabeledContent(row.name, value: "\(row.count)")
      }
      Button("Seed demo data") {
        DemoSeeder.seedBaseCategories()
        DemoSeeder.seedDemoProfile()
        refreshCounts()
      }
      Button("Erase all data", role: .destructive) {
        showEraseConfirmation = true
      }
    } header: {
      Text("Storage")
    }
  }
  
  private var schemaVersion: String {
    let version = CurrentSchema.versionIdentifier
    return "\(version.major).\(version.minor).\(version.patch)"
  }
}
