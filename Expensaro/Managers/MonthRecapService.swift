//
//  MonthRecapService.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/30/23.
//

import SwiftUI
import Charts
import ExpensaroUIKit
import RealmSwift

final class MonthRecapService: ObservableObject {
  @Published var budgetData: (Double, Double, Double) = (0.0, 0.0, 0.0)
  @Published var goalsData: Double = 0.0
  @Published var groupedTransactions: [GroupedTransactionsBySection] = []
  @Published var isLocked: Bool = true
  
  var recapMonth: String {
    formattedDate(date: getPastMonthDates().0)
  }
  
  let sampleTransactions: [Transaction] = [
    Source.Realm.createTransaction(name: "Gaming Laptop Purchase", date: Date(), category: ("Electronics", "💻", .lifestyle), amount: 1200.00, type: "Credit Card", note: "Ordered the latest gaming laptop."),
    Source.Realm.createTransaction(name: "Organic Grocery Haul", date: Date(), category: ("Groceries", "🛒", .lifestyle), amount: 150.75, type: "Debit Card", note: "Purchased organic groceries for the week."),
    Source.Realm.createTransaction(name: "Smart Home Energy Bill", date: Date(), category: ("Utilities", "⚡", .housing), amount: 80.50, type: "Online Banking", note: "Paid monthly bill for smart home energy management."),
    Source.Realm.createTransaction(name: "Michelin Star Dining", date: Date(), category: ("Dining", "🍽️", .food), amount: 75.30, type: "Cash", note: "Enjoyed a gourmet dinner at a Michelin-starred restaurant."),
    Source.Realm.createTransaction(name: "Streaming Service Renewal", date: Date(), category: ("Subscription", "🎬", .entertainment), amount: 99.99, type: "PayPal", note: "Renewed annual subscription for deluxe 4K streaming."),
    Source.Realm.createTransaction(name: "Fitness Equipment Purchase", date: Date(), category: ("Sports", "🏋️", .lifestyle), amount: 300.00, type: "Credit Card", note: "Bought new fitness equipment for home workouts."),
    Source.Realm.createTransaction(name: "Bookstore Splurge", date: Date(), category: ("Books", "📚", .lifestyle), amount: 45.50, type: "Debit Card", note: "Treated myself to a selection of new books."),
    Source.Realm.createTransaction(name: "Home Decor Shopping", date: Date(), category: ("Home", "🛋️", .housing), amount: 200.00, type: "Credit Card", note: "Purchased new decor items for the living room."),
    Source.Realm.createTransaction(name: "Weekend Getaway Expenses", date: Date(), category: ("Travel", "✈️", .lifestyle), amount: 500.00, type: "Credit Card", note: "Spent on accommodation and dining during the weekend trip."),
    Source.Realm.createTransaction(name: "Car Maintenance", date: Date(), category: ("Automotive", "🚗", .other), amount: 120.00, type: "Debit Card", note: "Routine maintenance for the car."),
    Source.Realm.createTransaction(name: "Tech Gadget Pre-order", date: Date(), category: ("Electronics", "🔧", .lifestyle), amount: 800.00, type: "Credit Card", note: "Pre-ordered the latest tech gadget."),
    Source.Realm.createTransaction(name: "Health Insurance Premium", date: Date(), category: ("Insurance", "🏥", .other), amount: 150.00, type: "Online Banking", note: "Paid monthly health insurance premium."),
    Source.Realm.createTransaction(name: "Concert Tickets", date: Date(), category: ("Entertainment", "🎤", .entertainment), amount: 120.00, type: "Credit Card", note: "Bought tickets for upcoming concert."),
    Source.Realm.createTransaction(name: "Home Office Upgrade", date: Date(), category: ("Office", "🖥️", .other), amount: 250.00, type: "Debit Card", note: "Upgraded home office setup with new equipment."),
    Source.Realm.createTransaction(name: "Coffee Shop Treat", date: Date(), category: ("Dining", "☕", .food), amount: 10.50, type: "Cash", note: "Indulged in a special coffee treat."),
    Source.Realm.createTransaction(name: "Renovation Supplies", date: Date(), category: ("Home", "🔨", .housing), amount: 350.00, type: "Credit Card", note: "Purchased supplies for home renovation."),
    Source.Realm.createTransaction(name: "Charitable Donation", date: Date(), category: ("Charity", "🤝", .lifestyle), amount: 50.00, type: "Online Banking", note: "Contributed to a local charity.")
  ]
  
  init() {
    fetchTransactions()
    calculateBudget()
    calculateGoals()
  }
  
  private func groupSections(with array: [Transaction]) {
    var groupedTransactions: [CategoriesSection: [Transaction]] {
      Dictionary(grouping: array) { transaction in
        return transaction.categorySection
      }
    }
    self.groupedTransactions = groupedTransactions.map { section, transactions in
      GroupedTransactionsBySection(transactions: transactions, section: section)
    }
  }
  
  func calculateBudget() {
    let realm = try! Realm()
    let startDate = getPastMonthDates().0
    let endDate = getPastMonthDates().1
    let predicate = NSPredicate(format: "dateCreated >= %@ AND dateCreated <= %@", startDate as NSDate, endDate as NSDate)
    let addedFundsPredicate = NSPredicate(format: "date >= %@ AND date <= %@ AND categoryName == %@", startDate as NSDate, endDate as NSDate, "Added funds")
    let pastMonthBudget = realm.objects(Budget.self).filter(predicate)
    
    if !pastMonthBudget.isEmpty, let budget = pastMonthBudget.first {
      budgetData.0 = budget.initialAmount
      let pastAddedFunds = realm.objects(Transaction.self).filter(addedFundsPredicate)
      if pastAddedFunds.isEmpty {
        budgetData.1 = 780
      } else {
        var addedFundsValue = pastAddedFunds.toArray().reduce(0) { $0 + $1.amount }
        budgetData.1 = addedFundsValue
      }
    } else {
      budgetData.0 = 2000
      budgetData.1 = 780
    }
  }
  
  func calculateGoals() {
    let realm = try! Realm()
    let startDate = getPastMonthDates().0
    let endDate = getPastMonthDates().1
    let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
    
    let goalContributions = realm.objects(GoalTransaction.self).filter(predicate)
    
    if goalContributions.isEmpty {
      goalsData = 2450
    } else {
      goalsData = goalContributions.toArray().reduce(0) {$0 + $1.amount }
    }
  }
  
  // Transactions which exclude refill type
  func fetchTransactions() {
    let realm = try! Realm()
    let startDate = getPastMonthDates().0
    let endDate = getPastMonthDates().1
    let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND categoryName != %@", startDate as NSDate, endDate as NSDate, "Added funds")
    let pastMonthTransactions = realm.objects(Transaction.self).filter(predicate)
    
    if pastMonthTransactions.isEmpty {
      isLocked = true
      budgetData.2 = 1600
      groupSections(with: sampleTransactions)
    }
    else {
      isLocked = false
      budgetData.2 = pastMonthTransactions.toArray().reduce(0) {$0 + $1.amount }
      groupSections(with: pastMonthTransactions.toArray())
    }
  }
}

// MARK: Struct to combine transactions by category section
struct GroupedTransactionsBySection: Identifiable {
  var id = UUID()
  var transactions: [Transaction]
  var section: CategoriesSection
  
  var totalAmount: Double {
    return transactions.reduce(0) { $0 + $1.amount }
  }
  
  private var groupedTransactionsByCategory: [String: [Transaction]] {
    return Dictionary(grouping: transactions, by: { $0.categoryName })
  }
  
  var totalAmountByCategory: [(String, Double, String)] {
    return groupedTransactionsByCategory.map { categoryName, transactions in
      let totalAmount = transactions.reduce(0) { $0 + $1.amount }
      let categoryIcon = transactions.first?.categoryIcon ?? ""
      return (categoryName, totalAmount, categoryIcon)
    }
  }
}


struct MonthRecapServiceView: View {
  @StateObject var service = MonthRecapService()
  var body: some View {
    VStack {
      Button {
        
      } label: {
        Text("Group transactions")
      }
      
      VStack {
        Text(service.recapMonth)
      }
      
      VStack {
        ForEach(service.groupedTransactions, id: \.section) { data in
          VStack {
            HStack {
              Text(data.section.header)
                .foregroundColor(data.section.progressColor)
                .font(.headlineBold)
              Text(data.totalAmount.withDecimals)
            }
            ForEach(data.totalAmountByCategory, id: \.0) { categoryName, totalAmount, categoryIcon in
              HStack {
                Text(categoryName)
                Text(totalAmount.clean)
                Text(categoryIcon)
              }
            }
            Divider()
          }
        }
      }
      
      Chart {
        ForEach(service.groupedTransactions, id: \.section) { data in
          
          BarMark(
            x: .value("", data.totalAmount),
            stacking: .normalized
          )
          .foregroundStyle(data.section.progressColor)
        }
      }
      .chartLegend(.hidden)
      .chartXAxis(.hidden)
      .frame(height: 40)
      .cornerRadius(5)
      .applyMargins()
    }
  }
}

#Preview {
  MonthRecapServiceView()
}

func getPastMonthDates() -> (Date, Date) {
  let currentDate = Date()
  let calendar = Calendar.current
  
  // Get the first day of the current month
  let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: currentDate)))!
  
  // Calculate the start of the previous month
  let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
  
  // Get the last day of the previous month
  let endOfPreviousMonth = calendar.date(byAdding: .day, value: -1, to: startOfMonth)!
  
  return (startOfPreviousMonth, endOfPreviousMonth)
}

func formattedDate(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMMM"
  return formatter.string(from: date)
}
