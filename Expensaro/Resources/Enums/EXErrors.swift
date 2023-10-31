//
//  EXErrors.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/23/23.
//

import SwiftUI

/// Enum with types of validation errors
enum EXErrors {
  case none
  case emptyName
  case zeroAmount
  case budgetExceed
  case zeroBudget
  
  var text: String {
    switch self {
    case .none:
      return ""
    case .emptyName:
      return "Name field cannot be empty"
    case .zeroAmount:
      return "Amount cannot be $0"
    case .budgetExceed:
      return "You are over  the budget"
    case .zeroBudget:
      return "You need to create a budget first"
    }
  }
}
