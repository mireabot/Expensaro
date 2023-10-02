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
  }
  
  enum Strings {
    enum Categories {
      enum Images {
        static let animals = "animals"
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
      }
    }
  }
}
