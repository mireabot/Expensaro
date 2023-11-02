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
  @Persisted var icon: String
  @Persisted var name: String
}

extension Results {
  func toArray() -> [Element] {
    return self.map { $0 }
  }
}

// MARK: Default categories for app preload
enum DefaultCategories {
  static var clothes: Category {
    let category = Category()
    category.name = CategoryDescription.clothes.name
    category.icon = CategoryDescription.clothes.icon
    return category
  }
  
  static var bills: Category {
    let category = Category()
    category.name = CategoryDescription.bills.name
    category.icon = CategoryDescription.bills.icon
    return category
  }
  
  static var education: Category {
    let category = Category()
    category.name = CategoryDescription.education.name
    category.icon = CategoryDescription.education.icon
    return category
  }
  
  static var medicine: Category {
    let category = Category()
    category.name = CategoryDescription.medicine.name
    category.icon = CategoryDescription.medicine.icon
    return category
  }
  
  static var hobby: Category {
    let category = Category()
    category.name = CategoryDescription.hobby.name
    category.icon = CategoryDescription.hobby.icon
    return category
  }
  
  static var travel: Category {
    let category = Category()
    category.name = CategoryDescription.travel.name
    category.icon = CategoryDescription.travel.icon
    return category
  }
  
  static var entertainment: Category {
    let category = Category()
    category.name = CategoryDescription.entertainment.name
    category.icon = CategoryDescription.entertainment.icon
    return category
  }
  
  static var subscriptions: Category {
    let category = Category()
    category.name = CategoryDescription.subscriptions.name
    category.icon = CategoryDescription.subscriptions.icon
    return category
  }
  
  static var goingOut: Category {
    let category = Category()
    category.name = CategoryDescription.goingOut.name
    category.icon = CategoryDescription.goingOut.icon
    return category
  }
  
  static var groceries: Category {
    let category = Category()
    category.name = CategoryDescription.groceries.name
    category.icon = CategoryDescription.groceries.icon
    return category
  }
  
  static var utilities: Category {
    let category = Category()
    category.name = CategoryDescription.utilities.name
    category.icon = CategoryDescription.utilities.icon
    return category
  }
  
  static var shopping: Category {
    let category = Category()
    category.name = CategoryDescription.shopping.name
    category.icon = CategoryDescription.shopping.icon
    return category
  }
  
  static var car: Category {
    let category = Category()
    category.name = CategoryDescription.car.name
    category.icon = CategoryDescription.car.icon
    return category
  }
  
  static var publicTransport: Category {
    let category = Category()
    category.name = CategoryDescription.publicTransport.name
    category.icon = CategoryDescription.publicTransport.icon
    return category
  }
  
  static var other: Category {
    let category = Category()
    category.name = CategoryDescription.other.name
    category.icon = CategoryDescription.other.icon
    return category
  }
  
  static var delivery: Category {
    let category = Category()
    category.name = CategoryDescription.delivery.name
    category.icon = CategoryDescription.delivery.icon
    return category
  }
  
  static var gaming: Category {
    let category = Category()
    category.name = CategoryDescription.gaming.name
    category.icon = CategoryDescription.gaming.icon
    return category
  }
  
  static var animals: Category {
    let category = Category()
    category.name = CategoryDescription.animals.name
    category.icon = CategoryDescription.animals.icon
    return category
  }
  
  static let defaultCategories = [
    clothes,
    education,
    medicine,
    hobby,
    travel,
    entertainment,
    subscriptions,
    goingOut,
    groceries,
    utilities,
    shopping,
    car,
    publicTransport,
    other,
    delivery,
    gaming,
    animals,
    bills
  ]
}

func compareAndMergeArrays(array1: [Category], realm: Realm) {
  let namesSet = Set(array1.map { $0.name })
  let differingObjects = DefaultCategories.defaultCategories.filter { !namesSet.contains($0.name) }
  if !differingObjects.isEmpty {
    print("Objects that are different:")
    for obj in differingObjects {
      print("Name: \(obj.name)")
    }
    // Merge differing objects into the Realm
    try? realm.write {
      realm.add(differingObjects, update: .modified)
    }
  } else {
    print("No differences found.")
  }
}
