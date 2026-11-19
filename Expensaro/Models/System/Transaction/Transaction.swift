//
//  Transaction.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/3/23.
//

import SwiftUI
import ExpensaroUIKit
import SwiftData

extension ExpensaroSchemaV1 {
  @Model
  final class Transaction {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String = ""
    var amount: Double = 0
    var type: String = ""
    var date: Date = Date()
    var categoryName: String = "Other"
    var categoryIcon: String = "📔"
    var categorySectionRaw: String = CategoriesSection.other.rawValue
    var note: String = ""

    init() {}

    var categorySection: CategoriesSection {
      get { CategoriesSection(rawValue: categorySectionRaw) ?? .other }
      set { categorySectionRaw = newValue.rawValue }
    }
  }
}
