//
//  Schema.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Foundation
import SwiftData

// MARK: - Versioned schema
// Models are nested in the versioned schema from V1 so later versions can be staged.
// Adding V2: copy the models into `ExpensaroSchemaV2`, repoint the typealiases below,
// append V2 to `ExpensaroMigrationPlan.schemas` and add a stage. Adding a property with
// a default is `.lightweight`; adding `.unique` or changing a type needs `.custom`.
enum ExpensaroSchemaV1: VersionedSchema {
  static let versionIdentifier = Schema.Version(1, 0, 0)

  static var models: [any PersistentModel.Type] {
    [
      Budget.self,
      Transaction.self,
      DailyTransaction.self,
      Category.self,
      Goal.self,
      GoalTransaction.self,
      RecurringTransaction.self,
      PaymentContributions.self
    ]
  }
}

enum ExpensaroMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] {
    [ExpensaroSchemaV1.self]
  }

  static var stages: [MigrationStage] {
    []
  }
}

// `Transaction` shadows `SwiftUI.Transaction` inside this module, as the Realm model did.
// Use `SwiftUI.Transaction` explicitly if a file ever needs the SwiftUI type.
typealias CurrentSchema = ExpensaroSchemaV1
typealias Budget = CurrentSchema.Budget
typealias Transaction = CurrentSchema.Transaction
typealias DailyTransaction = CurrentSchema.DailyTransaction
typealias Category = CurrentSchema.Category
typealias Goal = CurrentSchema.Goal
typealias GoalTransaction = CurrentSchema.GoalTransaction
typealias RecurringTransaction = CurrentSchema.RecurringTransaction
typealias PaymentContributions = CurrentSchema.PaymentContributions

// MARK: - Container
@MainActor
enum AppModelStore {
  /// The one container for the app. Injected at the app root and in `CustomHostingController`,
  /// and used directly by managers that run outside the view tree.
  static let container: ModelContainer = makeContainer(inMemory: false)

  /// In-memory container seeded with demo data, for previews
  static let preview: ModelContainer = {
    let container = makeContainer(inMemory: true)
    DemoSeeder.seedBaseCategories(in: container.mainContext)
    DemoSeeder.seedDemoProfile(in: container.mainContext)
    return container
  }()

  static var mainContext: ModelContext {
    container.mainContext
  }

  static var storeURL: URL? {
    container.configurations.first?.url
  }

  private static func makeContainer(inMemory: Bool) -> ModelContainer {
    let schema = Schema(versionedSchema: CurrentSchema.self)
    let configuration = ModelConfiguration("Expensaro", schema: schema, isStoredInMemoryOnly: inMemory)
    do {
      return try ModelContainer(for: schema, migrationPlan: ExpensaroMigrationPlan.self, configurations: configuration)
    } catch {
      fatalError("Unable to create the SwiftData container: \(error)")
    }
  }

  // MARK: Maintenance

  static func rowCounts(in context: ModelContext? = nil) -> [(name: String, count: Int)] {
    let context = context ?? mainContext
    return CurrentSchema.models.map { type in
      (String(describing: type), count(of: type, in: context))
    }
  }

  /// Deletes every row of every model, one fetch-and-delete per type. Saving after each
  /// type means rows already removed by a cascade are not fetched again, and nothing
  /// depends on batch deletes honouring delete rules.
  static func eraseAllData(in context: ModelContext? = nil) {
    let context = context ?? mainContext
    for type in CurrentSchema.models {
      deleteAll(of: type, in: context)
      try? context.save()
    }
  }

  private static func count<T: PersistentModel>(of type: T.Type, in context: ModelContext) -> Int {
    (try? context.fetchCount(FetchDescriptor<T>())) ?? 0
  }

  private static func deleteAll<T: PersistentModel>(of type: T.Type, in context: ModelContext) {
    let rows = (try? context.fetch(FetchDescriptor<T>())) ?? []
    rows.forEach { context.delete($0) }
  }
}
