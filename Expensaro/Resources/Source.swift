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
      static let close = Image(systemName: "xmark")
      static let checkmark = Image(systemName: "checkmark")
      static let back = Image(systemName: "arrow.backward")
    }
    enum Tabs {
      static let home = "tray.full"
      static let goals = "target"
      static let overview = "chart.bar.xaxis"
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
      static let notifications = Image(systemName: " app.badge")
      static let analytics = Image(systemName: "chart.xyaxis.line")
      static let scan = Image(systemName: "doc.viewfinder")
      static let timer = Image("timer")
      static let settings = Image(systemName: "gearshape")
    }
    enum ButtonIcons {
      static let add = Image("buttonAdd")
      static let how = Image("buttonHow")
    }
    enum InfoCardIcon {
      static let month2month = Image(systemName: "chart.line.uptrend.xyaxis")
      static let topCategory = Image(systemName: "trophy")
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
