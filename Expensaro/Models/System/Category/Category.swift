//
//  Category.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/12/23.
//

import SwiftUI
import RealmSwift

final class Category: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var icon: String = "📔"
  @Persisted var name: String
  @Persisted var tag: CategoriesTag = .base
  @Persisted var section: CategoriesSection = .other
}

/// Tag for categories
/// base for pre-loaded
/// custom for added by user
enum CategoriesTag: String, CaseIterable, PersistableEnum {
  case base
  case custom
}

/// Section for categories
enum CategoriesSection: String, CaseIterable, PersistableEnum {
  case food
  case housing
  case transportation
  case entertainment
  case lifestyle
  case other
  
  var header: String {
    switch self {
    case .food:
      return "Food"
    case .housing:
      return "Housing"
    case .transportation:
      return "Transportation"
    case .entertainment:
      return "Entertainment"
    case .lifestyle:
      return "Lifestyle"
    case .other:
      return "Other"
    }
  }
  
  var progressColor: Color {
    switch self {
    case .food:
      return Color(red: 0.231, green: 0.325, blue: 0.612) // #3b539c
    case .housing:
      return Color(red: 0.561, green: 0.651, blue: 0.835) // #8fa6d5
    case .transportation:
      return Color(red: 0.341, green: 0.694, blue: 0.388) // #57b163
    case .entertainment:
      return Color(red: 0.918, green: 0.827, blue: 0.384) // #ead362
    case .lifestyle:
      return Color(red: 0.878, green: 0.612, blue: 0.384) // #e09c62
    case .other:
      return Color(red: 0.576, green: 0.576, blue: 0.576) // #939393
    }
  }
}
