//
//  ActiveRecord.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

/// Models persist themselves: views call `try model.insert()` / `.save()` / `.delete()`
/// and read through the named `FetchDescriptor`s each model declares in its `+Record` file.
/// Not named `Model`, which would clash with the `@Model` macro.
protocol ActiveRecord: PersistentModel {}

extension ActiveRecord {
  static var all: FetchDescriptor<Self> { FetchDescriptor() }

  /// Inserts into `context`, or the app's main context when nil. The default is resolved in the body
  /// because Swift 5 mode cannot evaluate a main-actor default argument.
  @MainActor
  func insert(into context: ModelContext? = nil) throws {
    let context = context ?? AppModelStore.mainContext
    context.insert(self)
    try context.save()
  }

  @MainActor
  func save() throws {
    try modelContext?.save()
  }

  @MainActor
  func delete() throws {
    guard let context = modelContext else { return }
    context.delete(self)
    try context.save()
  }
}
