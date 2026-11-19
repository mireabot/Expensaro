//
//  DemoSeeder.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

/// Inserts the demo and default data from `Source.DefaultData`.
/// Used by onboarding, the Debug menu and the preview container.
@MainActor
enum DemoSeeder {
  /// Inserts the base categories whose names are not stored yet, so running it twice adds nothing
  static func seedBaseCategories(in context: ModelContext? = nil) {
    let context = context ?? AppModelStore.mainContext
    Source.DefaultData.loadedCategories.forEach { try? $0.addIfMissing(into: context) }
  }

  static func seedDemoProfile(in context: ModelContext? = nil) {
    let context = context ?? AppModelStore.mainContext
    let budgets = [Source.DefaultData.sampleBudget, Source.DefaultData.samplePreviousBudget]
    insert(budgets, into: context)
    insert(Source.DefaultData.sampleTransactions, into: context)
    insert(Source.DefaultData.sampleRecurringPayments, into: context)
    insert(Source.DefaultData.sampleGoals, into: context)
  }

  static func seedLoadedTransactions(in context: ModelContext? = nil) {
    let context = context ?? AppModelStore.mainContext
    insert(Source.DefaultData.loadedTransactions, into: context)
  }

  static func seedSameCategoryTransactions(in context: ModelContext? = nil) {
    let context = context ?? AppModelStore.mainContext
    insert(Source.DefaultData.sampleTransactionsWithCategory, into: context)
  }

  // One save per batch: `ActiveRecord.insert(into:)` saves per row, which is slow for the large demo sets
  private static func insert(_ models: [some PersistentModel], into context: ModelContext) {
    models.forEach { context.insert($0) }
    try? context.save()
  }
}
