//
//  Category+Record.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

extension Category: ActiveRecord {
  static var byName: FetchDescriptor<Category> {
    FetchDescriptor(sortBy: [SortDescriptor(\.name)])
  }

  static func named(_ name: String) -> FetchDescriptor<Category> {
    FetchDescriptor(predicate: #Predicate { $0.name == name })
  }

  /// Inserts the category unless one with the same name is already stored.
  /// Returns whether it was inserted.
  @MainActor
  @discardableResult
  func addIfMissing(into context: ModelContext? = nil) throws -> Bool {
    let context = context ?? AppModelStore.mainContext
    guard try context.fetchCount(Self.named(name)) == 0 else { return false }
    try insert(into: context)
    return true
  }
}
