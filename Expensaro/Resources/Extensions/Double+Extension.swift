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
}
