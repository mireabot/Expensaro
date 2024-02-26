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
      static let noDailyTransactions = Image("noDailyTransactions")
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
      static let rateApp = Image("rateApp")
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
    enum Previews {
      static let transactionInsightsPreview = Image("transactionInsightsPreview")
      static let dailyTransactionsInsightsPreview = Image("dailyTransactionsInsightsPreview")
    }
  }
  
  enum Strings {
    // Empty States strings
    enum EmptyStateType {
      case noBudget
      case noExpenses
      case noRecurrentPayments
      case noGoals
      
      var title: String {
        switch self {
        case .noBudget:
          return "No Budget Set"
        case .noExpenses:
          return "No Expenses Yet"
        case .noRecurrentPayments:
          return "Add Your Recurring Payments"
        case .noGoals:
          return "You have no active goals"
        }
      }
      
      var text: String {
        switch self {
        case .noBudget:
          return "You haven’t set up a budget for this month yet"
        case .noExpenses:
          return "You haven’t added any expenses for this month"
        case .noRecurrentPayments:
          return "Bills, subscriptions, and more"
        case .noGoals:
          return ""
        }
      }
      
      var buttonText: String {
        switch self {
        case .noBudget:
          return "Set up monthly budget"
        case .noExpenses:
          return "Add expenses"
        case .noRecurrentPayments:
          return "Add"
        case .noGoals:
          return "Create goal"
        }
      }
    }
    // Segment Picker strings
    enum SegmentPickerType {
      case transactionType
      
      var firstTab: String {
        switch self {
        case .transactionType:
          return "Debit"
        }
      }
      
      var secondTab: String {
        switch self {
        case .transactionType:
          return "Credit"
        }
      }
    }
    // Info card strings
    enum InfoCardType {
      case goalHint
      case monthToMonth
      case topCategory
      case overviewUpdates
      
      var title: String {
        switch self {
        case .goalHint:
          return "How to close your goal faster?"
        case .monthToMonth:
          return "Your monthly financial snapshots"
        case .topCategory:
          return "Top category for each month"
        case .overviewUpdates:
          return "We are always working on new features"
        }
      }
      
      var text: String {
        switch self {
        case .goalHint:
          return ""
        case .monthToMonth:
          return "Gain financial clarity every month. See your budgets, goal milestones and spending habits"
        case .topCategory:
          return "See where you spent most of your budget each month"
        case .overviewUpdates:
          return "New analytics tools are coming each update"
        }
      }
    }
    // Toggle cards strings
    enum ToggleType {
      case notifications
      case analytics
      case reminders
      case eraseData
      case deleteAccount
      case paymentReminder
      
      var title: String {
        switch self {
        case .notifications:
          return "Push notifications"
        case .analytics:
          return "Performance and Analytics"
        case .reminders:
          return "Daily reminders"
        case .eraseData:
          return "Erase history"
        case .deleteAccount:
          return "Full wipe out"
        case .paymentReminder:
          return "Renewing reminder"
        }
      }
      var text: String {
        switch self {
        case .notifications:
          return "Get alerts about upcoming payments, insights and more"
        case .analytics:
          return "We will collect some data about app usage to deliver great experience"
        case .reminders:
          return "The easiest way to fail with your budget is to forget about it. We can remind you to add todays expenses at a time that suits you"
        case .eraseData:
          return "Remove all my added data"
        case .deleteAccount:
          return "Delete my profile and all related data"
        case .paymentReminder:
          return "You'll receive a payment reminder one day before it's due"
        }
      }
      
      var toggleTitle: String {
        switch self {
        case .notifications:
          return "Enable notifications"
        case .analytics:
          return "We will collect some data about app usage to deliver great experience"
        case .reminders:
          return "Activate reminders"
        case .eraseData:
          return ""
        case .deleteAccount:
          return ""
        case .paymentReminder:
          return "Enable reminder"
        }
      }
    }
    // Settings cards strings
    enum SettingsType {
      case categories
      case reminders
      case exportData
      case resetAccount
      case contact
      case appSettings
      case wishKit
      case rateApp
      
      var title: String {
        switch self {
        case .categories:
          return "Categories"
        case .reminders:
          return "Reminders"
        case .exportData:
          return "Export Data"
        case .resetAccount:
          return "Reset Data"
        case .contact:
          return "Contact"
        case .appSettings:
          return "General Settings"
        case .wishKit:
          return "Features Hub"
        case .rateApp:
          return "Rate App"
        }
      }
      
      var text: String {
        switch self {
        case .categories:
          return "Create, edit or remove any of categories"
        case .reminders:
          return "Set up reminders and get notified instantly"
        case .exportData:
          return "Export your financial activity to .csv file"
        case .resetAccount:
          return "Start over, or delete account data"
        case .contact:
          return "We'd love to hear what's on your mind"
        case .appSettings:
          return "Tailor settings to your preference"
        case .wishKit:
          return "Vote for new features or create your own"
        case .rateApp:
          return "Rate your experience with Expensaro?"
        }
      }
    }
    // Bottom previews strings
    enum BottomPreviewType {
      case spendings
      case topCategory
      case transactions
      
      var title: String {
        switch self {
        case .spendings:
          return "Analyze your spendings against your budget"
        case .topCategory:
          return "Top Category Trends"
        case .transactions:
          return "Selected category breakdown"
        }
      }
      
      var text: String {
        switch self {
        case .spendings:
          return "Unlock profound budget insights, track monthly goals, and explore detailed category breakdowns"
        case .topCategory:
          return "Track your primary spending category and amount spent"
        case .transactions:
          return "Explore averages, top purchases, and more in any category"
        }
      }
      
      var isButton: Bool {
        switch self {
        case .spendings:
          return true
        case .topCategory:
          return true
        case .transactions:
          return false
        }
      }
    }
    // Alerts strings
    enum AlertType {
      case deleteTransaction
      case deleteGoal
      case createReminder
      case deletePayment
      case createBudget
      
      var title: String {
        switch self {
        case .deleteTransaction:
          return "Delete transaction?"
        case .deleteGoal:
          return "Delete goal?"
        case .createReminder:
          return "Do you want to create reminder?"
        case .deletePayment:
          return "Delete recurring payment"
        case .createBudget:
          return "Proceed with Budget Creation?"
        }
      }
      
      var subTitle: String {
        switch self {
        case .deleteTransaction:
          return "This action is permanent and cannot be restored"
        case .deleteGoal:
          return "This action is permanent and cannot be restored"
        case .createReminder:
          return "Choose when to receive a push notification reminder for your upcoming payment"
        case .deletePayment:
          return "This action is permanent and cannot be restored"
        case .createBudget:
          return "Once created, your budget cannot be deleted or modified, except for adding funds"
        }
      }
      
      var primaryButtonText: String {
        switch self {
        case .deleteTransaction:
          return "Yes, delete transaction"
        case .deleteGoal:
          return "Yes, delete goal"
        case .createReminder:
          return "Yes, I'm in"
        case .deletePayment:
          return "Yes, delete payment"
        case .createBudget:
          return "Yes, confirm"
        }
      }
      
      var secondaryButtonText: String {
        switch self {
        case .deleteTransaction:
          return "No, leave transaction"
        case .deleteGoal:
          return "No, leave goal"
        case .createReminder:
          return "No, thank you"
        case .deletePayment:
          return "No, leave payment"
        case .createBudget:
          return "No, go back"
        }
      }
    }
    // Dialogs strings
    enum DialogType {
      case deleteReminders
      case eraseData
      
      var title: String {
        switch self {
        case .deleteReminders:
          return "Payments reminders"
        case .eraseData:
          return "Reset your account"
        }
      }
      
      var text: String {
        switch self {
        case .deleteReminders:
          return "Confirm to unsubscribe from all payment reminders. This action is irreversible."
        case .eraseData:
          return "Confirm to delete all your account data. This action is irreversible."
        }
      }
    }
    // Toasts strings
    enum EXToasts {
      case none
      case emptyName
      case zeroAmount
      case budgetExceed
      case zeroBudget
      case wrongDate
      case pastDate
      case remindersDeleted
      case feebackSent
      
      public var text: String {
        switch self {
        case .none:
          return ""
        case .emptyName:
          return "The name field cannot be empty"
        case .zeroAmount:
          return "Amount cannot be $0"
        case .budgetExceed:
          return "Budget exceeded"
        case .zeroBudget:
          return "You need to create a budget first"
        case .wrongDate:
          return "Date should be in current month"
        case .pastDate:
          return "Date cannot be in the past"
        case .remindersDeleted:
          return "You have unsubscribed from reminders"
        case .feebackSent:
          return "We got your information and will get back very shortly!"
        }
      }
      
      public var isSuccess: Bool {
        switch self {
        case .none:
          return false
        case .emptyName:
          return false
        case .zeroAmount:
          return false
        case .budgetExceed:
          return false
        case .zeroBudget:
          return false
        case .wrongDate:
          return false
        case .pastDate:
          return false
        case .remindersDeleted:
          return true
        case .feebackSent:
          return true
        }
      }
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
    
    static func createDailyTransaction(name: String, category: (String, String, CategoriesSection), amount: Double, type: String) -> DailyTransaction {
      let dailyTransaction = DailyTransaction()
      dailyTransaction.name = name
      dailyTransaction.amount = amount
      dailyTransaction.categoryName = category.0
      dailyTransaction.categoryIcon = category.1
      dailyTransaction.categorySection = category.2
      dailyTransaction.type = "Daily Transaction"
      return dailyTransaction
    }
  }
  
  static let wishKEY = "1279B306-A1C9-4CB0-8D14-4A2413F72075"
  static let aptaBaseKEY = "A-US-4693844111"
  static let adminMode = true
  
  enum DefaultData {
    // Sample transactions for analytics
    static let sampleTransactions: [Transaction] = [
      Source.Realm.createTransaction(name: "Supermarket Grocery Shopping", date: randomDateInCurrentMonth(), category: ("Food", "🛒", .food), amount: 150, type: "Debit", note: "Weekly groceries including fresh produce, meats, and household items"),
      Source.Realm.createTransaction(name: "Monthly Rent", date: randomDateInCurrentMonth(), category: ("Housing", "🏠", .other), amount: 800, type: "Debit", note: "Monthly rent for apartment"),
      Source.Realm.createTransaction(name: "Electricity Bill", date: randomDateInCurrentMonth(), category: ("Utilities", "💡", .other), amount: 100, type: "Debit", note: "Monthly electricity bill"),
      Source.Realm.createTransaction(name: "Water Bill", date: randomDateInCurrentMonth(), category: ("Utilities", "🚿", .other), amount: 40, type: "Debit", note: "Monthly water service"),
      Source.Realm.createTransaction(name: "Internet Service", date: randomDateInCurrentMonth(), category: ("Utilities", "🌐", .other), amount: 60, type: "Debit", note: "High-speed internet service"),
      Source.Realm.createTransaction(name: "Mobile Phone Bill", date: randomDateInCurrentMonth(), category: ("Telecom", "📱", .lifestyle), amount: 70, type: "Debit", note: "Family plan mobile service"),
      Source.Realm.createTransaction(name: "Fuel for Car", date: randomDateInCurrentMonth(), category: ("Car", "⛽️", .transportation), amount: 120, type: "Debit", note: "Monthly fuel for commuting"),
      Source.Realm.createTransaction(name: "Car Insurance", date: randomDateInCurrentMonth(), category: ("Insurance", "📄", .other), amount: 100, type: "Debit", note: "Monthly car insurance premium"),
      Source.Realm.createTransaction(name: "Dining Out", date: randomDateInCurrentMonth(), category: ("Food", "🍽️", .food), amount: 90, type: "Debit", note: "Dinner at a restaurant with family"),
      Source.Realm.createTransaction(name: "Gym Membership", date: randomDateInCurrentMonth(), category: ("Fitness", "🏋️", .lifestyle), amount: 50, type: "Debit", note: "Monthly gym membership fee"),
      Source.Realm.createTransaction(name: "Streaming Service Subscription", date: randomDateInCurrentMonth(), category: ("Entertainment", "🎵", .entertainment), amount: 15, type: "Debit", note: "Monthly subscription for music and movies"),
      Source.Realm.createTransaction(name: "Coffee Shop Visits", date: randomDateInCurrentMonth(), category: ("Take out", "☕️", .food), amount: 25, type: "Credit", note: "Weekly coffee treats"),
      Source.Realm.createTransaction(name: "Pharmacy Essentials", date: randomDateInCurrentMonth(), category: ("Medicine", "💊", .other), amount: 30, type: "Debit", note: "Medications and health supplies"),
      Source.Realm.createTransaction(name: "Pet Food and Supplies", date: randomDateInCurrentMonth(), category: ("Pets", "🐾", .other), amount: 60, type: "Debit", note: "Monthly supplies for pet care"),
      Source.Realm.createTransaction(name: "Online Shopping for Clothing", date: randomDateInCurrentMonth(), category: ("Clothing", "👕", .lifestyle), amount: 120, type: "Credit", note: "Seasonal wardrobe update"),
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
