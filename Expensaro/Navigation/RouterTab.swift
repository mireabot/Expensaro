//
//  RouterTab.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation

/// Root tabs, each with its own navigation path in `Router`.
/// The quick-add side button is a tab bar concern and is not a tab here.
enum RouterTab: Int, CaseIterable, Hashable, Identifiable {
  case home
  case goals
  case overview

  var id: Int {
    rawValue
  }
}
