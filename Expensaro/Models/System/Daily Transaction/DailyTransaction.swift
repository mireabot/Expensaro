//
//  DailyTransaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/16/24.
//

import SwiftUI
import RealmSwift

final class DailyTransaction: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var amount: Double
  @Persisted var type: String
  @Persisted var categoryName: String = "Other"
  @Persisted var categoryIcon: String = "📔"
  @Persisted var categorySection: CategoriesSection = .other
}
