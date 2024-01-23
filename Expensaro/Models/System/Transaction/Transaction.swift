//
//  Transaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

final class Transaction: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var amount: Double
  @Persisted var type: String
  @Persisted var date: Date
  @Persisted var categoryName: String = "Other"
  @Persisted var categoryIcon: String = "📔"
  @Persisted var categorySection: CategoriesSection = .other
  @Persisted var note: String
}
