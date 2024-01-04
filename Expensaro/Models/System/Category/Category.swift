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
      return Color(red: 0.749, green: 0.902, blue: 0.098) // #bfe619
    case .housing:
      return Color(red: 0.902, green: 0.349, blue: 0.098) // #e65919
    case .transportation:
      return Color(red: 0.118, green: 0.098, blue: 0.902) // #1e19e6
    case .entertainment:
      return Color(red: 0.902, green: 0.098, blue: 0.549) // #e6198c
    case .lifestyle:
      return Color(red: 0.098, green: 0.902, blue: 0.584) // #19e695
    case .other:
      return Color(uiColor: .systemGray5)
    }
  }
}
