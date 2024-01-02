//
//  RealmMigrator.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/13/23.
//

import Foundation
import RealmSwift

enum RealmMigrator {
  static private func migrationBlock(
    migration: Migration,
    oldSchemaVersion: UInt64
  ) {
    // Migration version 2
    if oldSchemaVersion < 1 {
      migration.enumerateObjects(ofType: Transaction.className()) { _, newObject in
        newObject?["note"] = ""
      }
    }
    
    // Migration version 2
    if oldSchemaVersion < 2 {
      migration.enumerateObjects(ofType: RecurringTransaction.className()) { _, newObject in
        newObject?["type"] = ""
      }
    }
    
    // Migration version 3
    if oldSchemaVersion < 3 {
      migration.enumerateObjects(ofType: RecurringTransaction.className()) { _, newObject in
        newObject?["schedule"] = RecurringSchedule.everyWeek
      }
    }
    
    // Migration version 4
    if oldSchemaVersion < 4 {
      migration.enumerateObjects(ofType: RecurringTransaction.className()) { _, newObject in
        newObject?["note"] = ""
      }
    }
    
    // Migration version 5
    if oldSchemaVersion < 5 {
      migration.enumerateObjects(ofType: Goal.className()) { _, newObject in
        newObject?["transactions"] = List<GoalTransaction>()
      }
    }
    
    // Migration version 6
    if oldSchemaVersion < 6 {
      migration.enumerateObjects(ofType: Goal.className()) { _, newObject in
        newObject?["dateCreated"] = Date()
      }
    }
    
    // Migration version 7
    if oldSchemaVersion < 7 {
      migration.enumerateObjects(ofType: Budget.className()) { _, newObject in
        newObject?["initialAmount"] = 2000
      }
    }
    
    // Migration version 8
    if oldSchemaVersion < 8 {
      migration.enumerateObjects(ofType: Category.className()) { _, newObject in
        newObject?["tag"] = CategoriesTag.base
        newObject?["section"] = CategoriesSection.other
      }
    }
    
    // Migration version 10
    if oldSchemaVersion < 10 {
      migration.enumerateObjects(ofType: Transaction.className()) { _, newObject in
        newObject?["categorySection"] = "Other"
      }
    }
    
    // Migration version 11 - Current
    if oldSchemaVersion < 11 {
      migration.enumerateObjects(ofType: Transaction.className()) { _, newObject in
        newObject?["categorySection"] = CategoriesSection.other
      }
    }
  }

  static var configuration: Realm.Configuration {
    Realm.Configuration(schemaVersion: 11, migrationBlock: migrationBlock)
  }
}
