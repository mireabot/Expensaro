//
//  RealmMigrator.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/13/23.
//

import SwiftUI
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
    
    // Migration version 4 - Current
    if oldSchemaVersion < 4 {
      migration.enumerateObjects(ofType: RecurringTransaction.className()) { _, newObject in
        newObject?["note"] = ""
      }
    }
  }

  static var configuration: Realm.Configuration {
    Realm.Configuration(schemaVersion: 4, migrationBlock: migrationBlock)
  }
}
