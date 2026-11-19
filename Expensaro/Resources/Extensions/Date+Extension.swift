//
//  Date+Extension.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI

extension Date{
  /// First moment of the current month. `#Predicate` cannot call functions, so capture this in a local first
  static var startOfCurrentMonth: Date {
    Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
  }
  
  /// Getting all dates in month
  func getAllDates() -> [Date] {
    let calendar = Calendar.current
    // getting start Date...
    let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    let range = calendar.range(of: .day, in: .month, for: startDate)!
    
    // getting date...
    return range.compactMap { day -> Date in
      return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
    }
  }
}
