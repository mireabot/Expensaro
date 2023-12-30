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
  @Persisted var icon: String = Source.Strings.Categories.Images.other
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
      return Color(red: 0.612, green: 0.22, blue: 0.282)
    case .housing:
      return Color(red: 1, green: 0.678, blue: 0.412)
    case .transportation:
      return Color(red: 0.961, green: 0.902, blue: 0.388)
    case .entertainment:
      return Color(red: 0.278, green: 0.659, blue: 0.741)
    case .lifestyle:
      return Color(red: 0.118, green: 0.22, blue: 0.533)
    case .other:
      return Color(uiColor: .systemGray5)
    }
  }
}
