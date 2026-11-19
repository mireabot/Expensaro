//
//  Category.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/12/23.
//

import SwiftUI
import SwiftData

extension ExpensaroSchemaV1 {
  @Model
  final class Category {
    @Attribute(.unique) var id: String = UUID().uuidString
    var icon: String = "📔"
    var name: String = ""
    var tagRaw: String = CategoriesTag.base.rawValue
    var sectionRaw: String = CategoriesSection.other.rawValue

    init() {}

    var tag: CategoriesTag {
      get { CategoriesTag(rawValue: tagRaw) ?? .base }
      set { tagRaw = newValue.rawValue }
    }

    var section: CategoriesSection {
      get { CategoriesSection(rawValue: sectionRaw) ?? .other }
      set { sectionRaw = newValue.rawValue }
    }
  }
}

/// Tag for categories
/// base for pre-loaded
/// custom for added by user
enum CategoriesTag: String, CaseIterable {
  case base
  case custom
}

/// Section for categories
enum CategoriesSection: String, CaseIterable {
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
