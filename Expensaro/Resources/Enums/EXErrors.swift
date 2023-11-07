//
//  EXErrors.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/23/23.
//

import SwiftUI

/// Enum with types of validation errors
enum EXErrors: CaseIterable {
  case none
  case emptyName
  case zeroAmount
  case budgetExceed
  case zeroBudget
  case wrongDate
  case pastDate
  
  var text: String {
    switch self {
    case .none:
      return ""
    case .emptyName:
      return "Name field cannot be empty"
    case .zeroAmount:
      return "Amount cannot be $0"
    case .budgetExceed:
      return "You are over the budget"
    case .zeroBudget:
      return "You need to create a budget first"
    case .wrongDate:
      return "Date should be in current month"
    case .pastDate:
      return "Date cannot be in the past"
    }
  }
}
