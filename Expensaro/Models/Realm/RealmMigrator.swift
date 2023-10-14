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
    if oldSchemaVersion < 1 {
      migration.enumerateObjects(ofType: Transaction.className()) { _, newObject in
        newObject?["note"] = ""
      }
    }
  }

  static var configuration: Realm.Configuration {
    Realm.Configuration(schemaVersion: 1, migrationBlock: migrationBlock)
  }
}
