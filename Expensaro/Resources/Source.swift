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
    }
    enum Tabs {
      static let home = "home"
      static let goals = "goals"
      static let overview = "overview"
    }
    enum EmptyStates {
      static let noBudget = Image("noBudget")
      static let noExpenses = Image("noExpenses")
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
      static let notifications = Image("notifications")
      static let analytics = Image("analytics")
      static let scan = Image("scan")
      static let timer = Image("timer")
      static let settings = Image("settings")
    }
    enum ButtonIcons {
      static let add = Image("buttonAdd")
      static let how = Image("buttonHow")
    }
    enum InfoCardIcon {
      static let month2month = Image("month2month")
      static let topCategory = Image("topCategory")
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
  }
}
