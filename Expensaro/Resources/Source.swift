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
      static let down = Image("down")
      static let up = Image("up")
      static let swipeDirections = Image("swipeDirections")
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
    enum AppFeatures {
      static let customCategories = Image("customCategories")
      static let goalSuccessRate = Image("goalSuccessRate")
      static let paymentAlerts = Image("paymentAlerts")
      static let previousMonthRecap = Image("previousMonthRecap")
      static let recapCategoriesBreakdown = Image("recapCategoriesBreakdown")
      static let selectedCategoryBreakdown = Image("selectedCategoryBreakdown")
      static let smartGoalsPaymentSuggestions = Image("smartGoalsPaymentSuggestions")
      static let topCategoryAnalytics = Image("topCategoryAnalytics")
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
    
    /// Function formates currency input field with comma
    /// - Parameters:
    ///   - value: currency string
    ///   - addingCharacter: adding comma or not
    /// - Returns: formatter string
    static func reformatTextValue(_ value: String, addingCharacter: Bool) -> String {
      let components = value.components(separatedBy: ".")
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      numberFormatter.maximumFractionDigits = components.count > 1 ? components.last!.count : 0
      
      if let integerPart = Int(components.first?.replacingOccurrences(of: ",", with: "") ?? "0"),
         let formattedIntegerPart = numberFormatter.string(from: NSNumber(value: integerPart)) {
        return formattedIntegerPart + (components.count > 1 ? ".\(components.last ?? "")" : "")
      }
      return value
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
    
    static func createBudget(amount: Double, date: Date, initialAmount: Double) -> Budget {
      let budget = Budget()
      budget.initialAmount = initialAmount
      budget.amount = amount
      budget.dateCreated = date
      return budget
    }
  }
  
  static let wishKEY = "1279B306-A1C9-4CB0-8D14-4A2413F72075"
  static let aptaBaseKEY = "A-US-4693844111"
  static let adminMode = true
  
  enum DefaultData {
    // Sample transactions for analytics
    static let sampleTransactions: [Transaction] = [
      Source.Realm.createTransaction(name: "Snack Vending", date: randomDateInCurrentMonth(), category: ("Food", "🥡", .food), amount: 10, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Grocery Shopping", date: randomDateInCurrentMonth(), category: ("Food", "🛒", .food), amount: 45.30, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Bookstore Purchase", date: randomDateInCurrentMonth(), category: ("Books", "📕", .lifestyle), amount: 25, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Gas Refill", date: randomDateInCurrentMonth(), category: ("Car", "🚗", .transportation), amount: 60, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Coffee Break", date: randomDateInCurrentMonth(), category: ("Take out", "☕️", .food), amount: 5.75, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Cinema Night", date: randomDateInCurrentMonth(), category: ("Tickets", "🎫", .entertainment), amount: 20, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Fast Food Lunch", date: randomDateInCurrentMonth(), category: ("Food", "🍔", .food), amount: 12.50, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Parking Charge", date: randomDateInCurrentMonth(), category: ("Car", "🅿️", .transportation), amount: 8, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Pharmacy Visit", date: randomDateInCurrentMonth(), category: ("Medicine", "💊", .other), amount: 30, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Taxi to Downtown", date: randomDateInCurrentMonth(), category: ("Taxi", "🚕", .lifestyle), amount: 22, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Online Subscription", date: randomDateInCurrentMonth(), category: ("Entertainment", "🎵", .entertainment), amount: 9.99, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Utility Bill", date: randomDateInCurrentMonth(), category: ("Utilities", "💡", .other), amount: 75, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Gym Membership", date: randomDateInCurrentMonth(), category: ("Fitness", "🏋️", .lifestyle), amount: 50, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Hardware Store", date: randomDateInCurrentMonth(), category: ("Home Improvement", "🛠️", .lifestyle), amount: 35.20, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Pet Food", date: randomDateInCurrentMonth(), category: ("Pets", "🐾", .other), amount: 18.45, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Train Ticket", date: randomDateInCurrentMonth(), category: ("Transport", "🚆", .transportation), amount: 15, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Haircut", date: randomDateInCurrentMonth(), category: ("Personal Care", "💇", .lifestyle), amount: 25, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Garden Supplies", date: randomDateInCurrentMonth(), category: ("Gardening", "🌷", .lifestyle), amount: 40.60, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Restaurant Dinner", date: randomDateInCurrentMonth(), category: ("Food", "🍽️", .food), amount: 55, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Electronics Store", date: randomDateInCurrentMonth(), category: ("Electronics", "🔌", .lifestyle), amount: 120, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Bakery Visit", date: randomDateInCurrentMonth(), category: ("Food", "🍞", .food), amount: 8.40, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Online Gaming", date: randomDateInCurrentMonth(), category: ("Games", "🎮", .entertainment), amount: 30, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Art Supplies", date: randomDateInCurrentMonth(), category: ("Art", "🖌️", .lifestyle), amount: 45, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Flower Shop", date: randomDateInCurrentMonth(), category: ("Gifts", "🌹", .other), amount: 35, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Bicycle Repair", date: randomDateInCurrentMonth(), category: ("Bike", "🚲", .transportation), amount: 20, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Book Club Subscription", date: randomDateInCurrentMonth(), category: ("Books", "📚", .lifestyle), amount: 12, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Dry Cleaning", date: randomDateInCurrentMonth(), category: ("Laundry", "🧺", .other), amount: 15, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Mobile Recharge", date: randomDateInCurrentMonth(), category: ("Telecom", "📱", .lifestyle), amount: 30, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Yoga Class", date: randomDateInCurrentMonth(), category: ("Wellness", "🧘", .lifestyle), amount: 20, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Veterinary Visit", date: randomDateInCurrentMonth(), category: ("Pets", "🐕", .other), amount: 60, type: "Credit", note: ""), // End of current month transactions
      Source.Realm.createTransaction(name: "Evening Snack", date: randomDateInPreviousMonth(), category: ("Food", "🥨", .food), amount: 8, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Book Club", date: randomDateInPreviousMonth(), category: ("Books", "📚", .lifestyle), amount: 15, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Fuel Top-Up", date: randomDateInPreviousMonth(), category: ("Car", "⛽️", .transportation), amount: 45, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Tea Time", date: randomDateInPreviousMonth(), category: ("Take out", "🍵", .food), amount: 3.50, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Concert Tickets", date: randomDateInPreviousMonth(), category: ("Tickets", "🎟️", .entertainment), amount: 60, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Deli Lunch", date: randomDateInPreviousMonth(), category: ("Food", "🥪", .food), amount: 12.75, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Toll Fees", date: randomDateInPreviousMonth(), category: ("Car", "🚦", .transportation), amount: 5, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Health Store", date: randomDateInPreviousMonth(), category: ("Medicine", "🌿", .other), amount: 26.40, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Uber Ride", date: randomDateInPreviousMonth(), category: ("Taxi", "🚖", .lifestyle), amount: 18, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Streaming Service", date: randomDateInPreviousMonth(), category: ("Entertainment", "📺", .entertainment), amount: 12.99, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Electricity Bill", date: randomDateInPreviousMonth(), category: ("Utilities", "⚡️", .other), amount: 70, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Fitness Class", date: randomDateInPreviousMonth(), category: ("Fitness", "🤸‍♀️", .lifestyle), amount: 30, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "DIY Project", date: randomDateInPreviousMonth(), category: ("Home Improvement", "🔨", .lifestyle), amount: 50, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Pet Supplies", date: randomDateInPreviousMonth(), category: ("Pets", "🐱", .other), amount: 22.30, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Bus Fare", date: randomDateInPreviousMonth(), category: ("Transport", "🚌", .transportation), amount: 2.50, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Barber Shop", date: randomDateInPreviousMonth(), category: ("Personal Care", "✂️", .lifestyle), amount: 18, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Nursery Purchase", date: randomDateInPreviousMonth(), category: ("Gardening", "🌻", .lifestyle), amount: 35, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Dine Out", date: randomDateInPreviousMonth(), category: ("Food", "🍖", .food), amount: 65, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Tech Gadgets", date: randomDateInPreviousMonth(), category: ("Electronics", "💻", .lifestyle), amount: 150, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Pastry Shop", date: randomDateInPreviousMonth(), category: ("Food", "🥐", .food), amount: 9.20, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Video Game Purchase", date: randomDateInPreviousMonth(), category: ("Games", "🕹️", .entertainment), amount: 50, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Art Gallery", date: randomDateInPreviousMonth(), category: ("Art", "🎨", .lifestyle), amount: 40, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Gift Shop", date: randomDateInPreviousMonth(), category: ("Gifts", "🎁", .other), amount: 30, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Bike Service", date: randomDateInPreviousMonth(), category: ("Bike", "🔧", .transportation), amount: 25, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Reading Subscription", date: randomDateInPreviousMonth(), category: ("Books", "🔖", .lifestyle), amount: 10, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Laundry Service", date: randomDateInPreviousMonth(), category: ("Laundry", "🧼", .other), amount: 20, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Cellular Plan", date: randomDateInPreviousMonth(), category: ("Telecom", "📞", .lifestyle), amount: 35, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Meditation Class", date: randomDateInPreviousMonth(), category: ("Wellness", "🕉️", .lifestyle), amount: 15, type: "Debit", note: ""),
      Source.Realm.createTransaction(name: "Vet Appointment", date: randomDateInPreviousMonth(), category: ("Pets", "🐢", .other), amount: 55, type: "Credit", note: ""),
      Source.Realm.createTransaction(name: "Café Visit", date: randomDateInPreviousMonth(), category: ("Food", "🍰", .food), amount: 12, type: "Debit", note: "")
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
    // Sample budget
    static let sampleBudget: Budget = Source.Realm.createBudget(amount: 1200, date: Date(), initialAmount: 3000)
    // Sample past budget
    static let samplePreviousBudget: Budget = Source.Realm.createBudget(amount: 3200, date: randomDateInPreviousMonth(), initialAmount: 5300)
    // Sample goals
    static let sampleGoals: [Goal] = [
      Source.Realm.createGoal(name: "Vacation Fund", amount: 1000, currentAmount: 500, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 90)),
      Source.Realm.createGoal(name: "New Laptop", amount: 1500, currentAmount: 1500, dueDate: Date().addingTimeInterval(60 * 60 * 24 * 90)),
      Source.Realm.createGoal(name: "Failed Goal", amount: 1000, currentAmount: 100, dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 30)),
    ]
  }
}

func randomDateInCurrentMonth() -> Date {
  let calendar = Calendar.current
  let today = Date()
  
  // Get the first day of the current month
  let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
  
  // Get the first day of the previous month
  let previousMonthStart = calendar.date(byAdding: .month, value: 0, to: currentMonthStart)!
  
  // Get the range of days in the previous month
  let range = calendar.range(of: .day, in: .month, for: previousMonthStart)!
  
  // Generate a random day in the previous month
  let randomDay = Int.random(in: range.lowerBound..<range.upperBound)
  
  // Return the random date in the previous month
  return calendar.date(bySetting: .day, value: randomDay, of: previousMonthStart)!
}

func randomDateInPreviousMonth() -> Date {
  let calendar = Calendar.current
  let today = Date()
  
  // Get the first day of the current month
  let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
  
  // Get the first day of the previous month
  let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)!
  
  // Get the range of days in the previous month
  let range = calendar.range(of: .day, in: .month, for: previousMonthStart)!
  
  // Generate a random day in the previous month
  let randomDay = Int.random(in: range.lowerBound..<range.upperBound)
  
  // Return the random date in the previous month
  return calendar.date(bySetting: .day, value: randomDay, of: previousMonthStart)!
}
