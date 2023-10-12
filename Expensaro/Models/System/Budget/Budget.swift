//
//  Budget.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/11/23.
//

import SwiftUI
import RealmSwift

class Budget: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var amount: Double
  @Persisted var dateCreated: Date = Date()
}
