//
//  DailyTransaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/16/24.
//

import SwiftUI
import SwiftData

extension ExpensaroSchemaV1 {
  @Model
  final class DailyTransaction {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String = ""
    var amount: Double = 0
    var type: String = ""
    var categoryName: String = "Other"
    var categoryIcon: String = "📔"
    var categorySectionRaw: String = CategoriesSection.other.rawValue
    // Realm kept insertion order; lists sort by this to preserve it
    var dateCreated: Date = Date()

    init() {}

    var categorySection: CategoriesSection {
      get { CategoriesSection(rawValue: categorySectionRaw) ?? .other }
      set { categorySectionRaw = newValue.rawValue }
    }
  }
}
