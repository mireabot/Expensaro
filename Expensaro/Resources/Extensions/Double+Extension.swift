//
//  Double+Extension.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/10/23.
//

import SwiftUI

extension Double {
  /// Present number without point digits
  var clean: String {
    return String(format: "%.0f", self)
  }
  
  /// Present number with 2 point digits
  var withDecimals: String {
    return String(format: "%.2f", self)
  }
  
  /// Converts amount intro currency with 2 decimals
  func formattedAsCurrency(with currencyCode: String?) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode ?? "USD"
    formatter.minimumFractionDigits = 2 // Always show at least two decimal places
    formatter.maximumFractionDigits = 2 // Maximum two decimal places
    
    return formatter.string(from: NSNumber(value: self)) ?? ""
  }
  
  /// Converts amount intro currency with 2 decimals (optional if .00)
  func formattedAsCurrencySolid(with currencyCode: String?) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode ?? "USD"
    formatter.minimumFractionDigits = 0 // No minimum fractional digits
    
    // Use different maximumFractionDigits based on whether the number has fractional part
    formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
    
    return formatter.string(from: NSNumber(value: self)) ?? ""
  }
}
