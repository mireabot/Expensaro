//
//  Source.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI

enum Source {
  enum Images {
    enum Navigation {
      static let close = Image("close")
      static let checkmark = Image("checkmark")
      static let back = Image("back")
      static let menu = Image("menu")
      static let swipeDown = Image("swipeDown")
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
      static let appTools = Image("appTools")
      static let reminder = Image("reminder")
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
    static func currentMonth() -> String {
      let currentDate = Date()
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMMM"
      
      return dateFormatter.string(from: currentDate)
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
    static func createTransaction(name: String, date: Date, category: (String, String), amount: Double, type: String) -> Transaction {
      let transaction = Transaction()
      transaction.name = name
      transaction.date = date
      transaction.categoryIcon = category.0
      transaction.categoryName = category.1
      transaction.amount = amount
      transaction.type = type
      
      return transaction
    }
  }
}
