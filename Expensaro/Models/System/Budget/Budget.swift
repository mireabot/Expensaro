//
//  Budget.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/11/23.
//

import SwiftUI
import RealmSwift

final class Budget: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var amount: Double
  @Persisted var initialAmount: Double
  @Persisted var dateCreated: Date = Date()
}
