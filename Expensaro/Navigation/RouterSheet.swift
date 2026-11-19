//
//  RouterSheet.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation

/// Screens the router presents as a sheet, one case per screen carrying only that screen's input.
/// Rendered by `withSheetDestinations(_:)`, see WithSheetDestinations.swift.
enum RouterSheet: Hashable, Identifiable {
  case featuresHub

  var id: Self {
    self
  }
}
