//
//  Source.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import ExpensaroUIKit

enum Source {
  enum Images {
    enum Navigation {
      static let close = Image("close")
      static let checkmark = Image("checkmark")
      static let back = Image("back")
      static let menu = Image("menu")
      static let swipeDown = Image("swipeDown")
      static let redirect = Image("redirect")
    }
    enum Tabs {
      static let home = "home"
      static let goals = "goals"
      static let overview = "overview"
    }
    enum EmptyStates {
      static let noBudget = Image(systemName: "dollarsign")
      static let noExpenses = Image(systemName: "list.bullet")
      static let noGoals = Image("noGoals")
      static let noTransactions = Image("noTransactions")
      static let noCategories = Image("noCategories")
      static let noInsights = Image("month2month")
      static let noRecurringPayments = Image("recurrentPayments")
      static let noGoalTransaction = Image("buttonTransaction")
    }
    enum Onboarding {
      static let onb1 = Image("onb1")
      static let onb2 = Image("onb2")
      static let onb3 = Image("onb3")
      static let transactions = Image("home")
      static let recurrentPayments = Image("recurrentPayments")
      static let goals = Image("goals")
    }
    enum System {
      static let notifications = Image(systemName: "app.badge")
      static let analytics = Image(systemName: "chart.xyaxis.line")
      static let scan = Image("scan")
      static let timer = Image("timer")
      static let settings = Image("settings")
      static let defaultCategory = Image(systemName: "archivebox.fill")
      static let completedGoal = Image("completedGoal")
      static let calendarWeek = Image("calendarWeek")
      static let calendarMonth = Image("calendarMonth")
      static let calendarYear = Image("calendarYear")
      static let transactionType = Image("transactionType")
      static let remove = Image("remove")
      static let alertError = Image("alertError")
      static let alertSuccess = Image("alertSuccess")
      static let appTools = Image("appTools")
      static let reminder = Image("reminder")
      static let arrowUp = Image("arrowUp")
      static let arrowDown = Image("arrowDown")
      static let smartWidget = Image("smartWidget")
    }
    enum Settings {
      static let categories = Image("categories")
      static let reminders = Image("reminders")
      static let exportData = Image("exportData")
      static let resetData = Image("resetData")
      static let contact = Image("contact")
      static let request = Image("request")
    }
    enum ButtonIcons {
      static let add = Image("buttonAdd")
      static let how = Image("buttonHow")
      static let send = Image("send")
      static let addTransaction = Image("buttonTransaction")
      static let addRecurrent = Image("buttonRecurrent")
      static let delete = Image("buttonDelete")
      static let edit = Image("buttonEdit")
      static let save = Image("buttonSave")
      static let share = Image("buttonShare")
      static let selector = Image("buttonSelect")
      static let note = Image("buttonNote")
    }
    enum InfoCardIcon {
      static let month2month = Image("month2month")
      static let topCategory = Image("topCategory")
      static let missedGoal = Image("missedGoal")
    }
    enum BottomInfo {
      static let spendings = Image("spendingsInfo")
      static let topCategory = Image("topCategoryInfo")
    }
  }
  
  enum Functions {
    /// Function which convertes date to string with format "MMM d, yyyy"
    /// - Parameter date: input date
    /// - Returns: string date
    static func showString(from date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM d, yyyy"
      return formatter.string(from: date)
    }
    
    /// Function which gets current month
    /// - Returns: String with current month
    static func currentMonth(date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMMM"
      return formatter.string(from: date)
    }
    
    /// Function which converts Date to TimeInterval for local notification date
    /// - Parameter date: Date to be converted
    /// - Returns: Converted date
    static func dateToTimeInterval(_ date: Date) -> TimeInterval {
      let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? Date()
      let timeInterval = modifiedDate.timeIntervalSince1970
      
      return timeInterval
    }
    
    
    /// Functions which converts date to local timezone
    /// - Parameter date: Date to convert
    /// - Returns: Converted date to local timezone
    static func localDate(with date: Date) -> Date {
      let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: date))
      guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: date) else {return Date()}
      
      return localDate
    }
    
    /// Function returns start and end dates of previous month
    /// - Returns: Date type variables
    static func getPastMonthDates() -> (Date, Date) {
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
  }
  
  enum Strings {
    enum Categories {
      enum Images {
        static let animals = "animals"
        static let bills = "bills"
        static let car = "car"
        static let clothes = "clothes"
        static let delivery = "delivery"
        static let education = "education"
        static let entertainment = "entertainment"
        static let gaming = "gaming"
        static let goingOut = "goingOut"
        static let groceries = "groceries"
        static let hobby = "hobby"
        static let medicine = "medicine"
        static let other = "other"
        static let publicTransport = "publicTransport"
        static let restaraunt = "restaraunt"
        static let shopping = "shopping"
        static let subscriptions = "recurrentPayments"
        static let travel = "travel"
        static let utilities = "utilities"
        static let income = "income"
      }
    }
  }
  
  enum Realm {
    /// Function which creates Transaction realm object
    /// - Parameters:
    ///   - name: name of Transaction
    ///   - date: date of Transaction
    ///   - category: category set of Transaction
    ///   - amount: amount of Transaction
    ///   - type: type of Transaction
    /// - Returns: Filled object Transaction
    static func createTransaction(name: String, date: Date, category: (String, String, CategoriesSection), amount: Double, type: String, note: String) -> Transaction {
      let transaction = Transaction()
      transaction.name = name
      transaction.amount = amount
      transaction.type = type
      transaction.date = date
      transaction.categoryName = category.0
      transaction.categoryIcon = category.1
      transaction.categorySection = category.2
      transaction.note = note
      
      return transaction
    }
    
    /// Function which creates Category realm object
    /// - Parameters:
    ///   - icon: icon of Category
    ///   - name: name of Category
    ///   - tag: tag of Category
    ///   - section: section of Category
    /// - Returns: Filled object Category
    static func createCategory(icon: String, name: String, tag: CategoriesTag, section: CategoriesSection) -> Category {
      let category = Category()
      category.icon = icon
      category.name = name
      category.tag = tag
      category.section = section
      
      return category
    }
    
    /// Fuction creates RecurringTransaction realm object
    /// - Parameters:
    ///   - name: payment name
    ///   - amount: payment amount
    ///   - dueDate: payment due date
    ///   - type: payment type
    ///   - category: payment category (Name, Icon)
    ///   - isReminder: payment reminder condition
    /// - Returns: Filled object of RecurringTransaction
    static func createRecurringPayment(name: String, amount: Double, dueDate: Date, type: String, category: (String, String), isReminder: Bool) -> RecurringTransaction {
      let transaction = RecurringTransaction()
      transaction.name = name
      transaction.amount = amount
      transaction.dueDate = dueDate
      transaction.type = type
      transaction.categoryName = category.0
      transaction.categoryIcon = category.1
      transaction.isReminder = isReminder
      return transaction
    }
    
    /// Function creates Goal realm object
    /// - Parameters:
    ///   - name: goal name
    ///   - amount: goal amount to save
    ///   - currentAmount: goal current saved amount
    ///   - dueDate: goal due date
    /// - Returns: Filled object of Goal
    static func createGoal(name: String, amount: Double, currentAmount: Double, dueDate: Date) -> Goal {
      let goal = Goal()
      goal.name = name
      goal.finalAmount = amount
      goal.currentAmount = currentAmount
      goal.dueDate = dueDate
      return goal
    }
    
    /// Function creates object of Payment Contribution
    /// - Parameters:
    ///   - amount: Payment to renew amount
    ///   - date: Date when payment was renewed
    static func createPaymentContribution(amount: Double, date: Date) -> PaymentContributions {
      let contribution = PaymentContributions()
      contribution.amount = amount
      contribution.date = date
      return contribution
    }
  }
  
  static let wishKEY = "1279B306-A1C9-4CB0-8D14-4A2413F72075"
  static let aptaBaseKEY = "A-US-4693844111"
  static let adminMode = true
  
  enum DefaultData {
    // Sample transactions for analytics
    static let sampleTransactions: [Transaction] = [
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
    // Sample transactions for selected analytics
    static let selectedTransactions: [Transaction] = [
      Source.Realm.createTransaction(name: "Dinner and Show", date: .now, category: ("","",.other), amount: 120, type: "", note: ""),
      Source.Realm.createTransaction(name: "Concert Extravaganza", date: .now, category: ("","",.other), amount: 80, type: "", note: ""),
      Source.Realm.createTransaction(name: "Amusement Park", date: .now, category: ("","",.other), amount: 75, type: "", note: ""),
      Source.Realm.createTransaction(name: "Movie Night", date: .now, category: ("","",.other), amount: 45, type: "", note: ""),
      Source.Realm.createTransaction(name: "Gaming Galore", date: .now, category: ("","",.other), amount: 60, type: "", note: ""),
      Source.Realm.createTransaction(name: "Escape Room", date: .now, category: ("","",.other), amount: 30, type: "", note: ""),
    ]
    // Sample transactions to add in account
    static let loadedTransactions: [Transaction] = [
      Source.Realm.createTransaction(name: "Snack Vending", date: .now, category: ("Food", "🥡", .food), amount: 10, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Bookstore Buy", date: .now, category: ("Books", "📕", .lifestyle), amount: 78.66, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Gas Station", date: .now, category: ("Car", "🚗", .transportation), amount: 56, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Coffee", date: .now, category: ("Take out", "☕️", .food), amount: 7.88, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Movie Ticket", date: .now, category: ("Tickets", "🎫", .entertainment), amount: 18, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Lunch Order", date: .now, category: ("Food", "🥡", .food), amount: 17, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Parking Fee", date: .now, category: ("Car", "🚗", .transportation), amount: 99, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Pharmacy", date: .now, category: ("Medicine", "🩹", .other), amount: 9.99, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Taxi Ride", date: .now, category: ("Taxi", "🚕", .lifestyle), amount: 55, type: "Credit", note: "")
    ]
    // Default categories which loading when setup
    static let loadedCategories: [Category] = [
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
    // Sample recurring payments
    static let sampleRecurringPayments: [RecurringTransaction] = [
      Source.Realm.createRecurringPayment(name: "Netflix", amount: 12.99, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(), type: "Debit", category: ("Subscription", "🔄"), isReminder: false),
      Source.Realm.createRecurringPayment(name: "Gym Membership", amount: 130, dueDate: Date(), type: "Credit", category: ("Subscription", "🔄"), isReminder: true)
    ]
    // Sample goals
    static let sampleGoals: [Goal] = [
      Source.Realm.createGoal(name: "Vacation Fund", amount: 1000, currentAmount: 500, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 90)),
      Source.Realm.createGoal(name: "New Laptop", amount: 1500, currentAmount: 1500, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 90)),
      Source.Realm.createGoal(name: "Failed Goal", amount: 1000, currentAmount: 100, dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 30)),
    ]
  }
}
