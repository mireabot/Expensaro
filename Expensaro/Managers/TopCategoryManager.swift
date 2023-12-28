//
//  TopCategoryManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/28/23.
//

import SwiftUI
import RealmSwift

final class TopCategoryManager: ObservableObject {
  let sampleData: [Transaction] = [
    Source.Realm.createTransaction(name: "Gaming Laptop Purchase", date: Date(), category: ("Electronics", "💻", "Technology"), amount: 1200.00, type: "Credit Card", note: "Ordered the latest gaming laptop."),
    Source.Realm.createTransaction(name: "Organic Grocery Haul", date: Date(), category: ("Groceries", "🛒", "Essentials"), amount: 150.75, type: "Debit Card", note: "Purchased organic groceries for the week."),
    Source.Realm.createTransaction(name: "Smart Home Energy Bill", date: Date(), category: ("Utilities", "⚡", "Bills"), amount: 80.50, type: "Online Banking", note: "Paid monthly bill for smart home energy management."),
    Source.Realm.createTransaction(name: "Michelin Star Dining", date: Date(), category: ("Dining", "🍽️", "Entertainment"), amount: 75.30, type: "Cash", note: "Enjoyed a gourmet dinner at a Michelin-starred restaurant."),
    Source.Realm.createTransaction(name: "Streaming Service Renewal", date: Date(), category: ("Subscription", "🎬", "Entertainment"), amount: 99.99, type: "PayPal", note: "Renewed annual subscription for deluxe 4K streaming."),
    Source.Realm.createTransaction(name: "Fitness Equipment Purchase", date: Date(), category: ("Sports", "🏋️", "Health"), amount: 300.00, type: "Credit Card", note: "Bought new fitness equipment for home workouts."),
    Source.Realm.createTransaction(name: "Bookstore Splurge", date: Date(), category: ("Books", "📚", "Entertainment"), amount: 45.50, type: "Debit Card", note: "Treated myself to a selection of new books."),
    Source.Realm.createTransaction(name: "Home Decor Shopping", date: Date(), category: ("Home", "🛋️", "Lifestyle"), amount: 200.00, type: "Credit Card", note: "Purchased new decor items for the living room."),
    Source.Realm.createTransaction(name: "Weekend Getaway Expenses", date: Date(), category: ("Travel", "✈️", "Entertainment"), amount: 500.00, type: "Credit Card", note: "Spent on accommodation and dining during the weekend trip."),
    Source.Realm.createTransaction(name: "Car Maintenance", date: Date(), category: ("Automotive", "🚗", "Maintenance"), amount: 120.00, type: "Debit Card", note: "Routine maintenance for the car."),
    Source.Realm.createTransaction(name: "Tech Gadget Pre-order", date: Date(), category: ("Electronics", "🔧", "Technology"), amount: 800.00, type: "Credit Card", note: "Pre-ordered the latest tech gadget."),
    Source.Realm.createTransaction(name: "Health Insurance Premium", date: Date(), category: ("Insurance", "🏥", "Bills"), amount: 150.00, type: "Online Banking", note: "Paid monthly health insurance premium."),
    Source.Realm.createTransaction(name: "Concert Tickets", date: Date(), category: ("Entertainment", "🎤", "Entertainment"), amount: 120.00, type: "Credit Card", note: "Bought tickets for upcoming concert."),
    Source.Realm.createTransaction(name: "Home Office Upgrade", date: Date(), category: ("Office", "🖥️", "Technology"), amount: 250.00, type: "Debit Card", note: "Upgraded home office setup with new equipment."),
    Source.Realm.createTransaction(name: "Coffee Shop Treat", date: Date(), category: ("Dining", "☕", "Entertainment"), amount: 10.50, type: "Cash", note: "Indulged in a special coffee treat."),
    Source.Realm.createTransaction(name: "Renovation Supplies", date: Date(), category: ("Home", "🔨", "Lifestyle"), amount: 350.00, type: "Credit Card", note: "Purchased supplies for home renovation."),
    Source.Realm.createTransaction(name: "Charitable Donation", date: Date(), category: ("Charity", "🤝", "Community"), amount: 50.00, type: "Online Banking", note: "Contributed to a local charity.")
  ]
  
  @Published var topCategory: (String, Double, Int) = ("", 0.0, 0)
  @Published var otherCategories: [(String, Double)] = []
  
  init() {}
  
  func groupAndFindMaxAmountCategory() {
    var categoryTotals: [String: (Double, Int)] = [:]
    
    // Group transactions by category and calculate total amount and count for each category
    for transaction in sampleData {
      let category = transaction.categoryName
      let currentTotal = categoryTotals[category, default: (0.0, 0)]
      categoryTotals[category] = (currentTotal.0 + transaction.amount, currentTotal.1 + 1)
    }
    
    // Find the category with the highest total amount
    if let maxCategory = categoryTotals.max(by: { $0.value.0 < $1.value.0 }) {
      topCategory.0 = maxCategory.key
      topCategory.1 = maxCategory.value.0
      topCategory.2 = maxCategory.value.1
    }
    
    updateOtherCategories()
  }
  
  private func updateOtherCategories() {
    var otherCategoriesTotals: [(String, Double)] = []
    
    if topCategory.0.isEmpty {
      return
    }
    
    // Group transactions by category and calculate total amount and count for each category
    for transaction in sampleData {
      let category = transaction.categoryName
      if category != topCategory.0 {
        let currentTotal = otherCategoriesTotals.first(where: { $0.0 == category }) ?? ("", 0.0)
        otherCategoriesTotals.removeAll(where: { $0.0 == category })
        otherCategoriesTotals.append((category, currentTotal.1 + transaction.amount))
      }
    }
    
    // Sort the otherCategoriesTotals by total amount in descending order
    otherCategoriesTotals.sort { $0.1 > $1.1 }
    
    otherCategories = otherCategoriesTotals
  }
}
