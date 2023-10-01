//
//  Date+Extension.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI

extension Date{
  
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
