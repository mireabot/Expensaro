//
//  Category.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/12/23.
//

import SwiftUI
import RealmSwift

class Category: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var icon: String
  @Persisted var name: String
}

// Default categories which are defined in app
enum DefaultCategories {
  static var clothes: Category {
    let category = Category()
    category.name = "Clothes"
    category.icon = Source.Strings.Categories.Images.clothes
    return category
  }
  
  static var education: Category {
    let category = Category()
    category.name = "Education"
    category.icon = Source.Strings.Categories.Images.education
    return category
  }
  
  static var medicine: Category {
    let category = Category()
    category.name = "Medical"
    category.icon = Source.Strings.Categories.Images.medicine
    return category
  }
  
  static var hobby: Category {
    let category = Category()
    category.name = "Hobby"
    category.icon = Source.Strings.Categories.Images.hobby
    return category
  }
  
  static var travel: Category {
    let category = Category()
    category.name = "Travel"
    category.icon = Source.Strings.Categories.Images.travel
    return category
  }
  
  static var entertainment: Category {
    let category = Category()
    category.name = "Entertainment"
    category.icon = Source.Strings.Categories.Images.entertainment
    return category
  }
  
  static var subscriptions: Category {
    let category = Category()
    category.name = "Subscription"
    category.icon = Source.Strings.Categories.Images.subscriptions
    return category
  }
  
  static var goingOut: Category {
    let category = Category()
    category.name = "Going out"
    category.icon = Source.Strings.Categories.Images.goingOut
    return category
  }
  
  static var groceries: Category {
    let category = Category()
    category.name = "Groceries"
    category.icon = Source.Strings.Categories.Images.groceries
    return category
  }
  
  static var utilities: Category {
    let category = Category()
    category.name = "Utilities"
    category.icon = Source.Strings.Categories.Images.utilities
    return category
  }
  
  static var shopping: Category {
    let category = Category()
    category.name = "Shopping"
    category.icon = Source.Strings.Categories.Images.shopping
    return category
  }
  
  static var car: Category {
    let category = Category()
    category.name = "Car"
    category.icon = Source.Strings.Categories.Images.car
    return category
  }
  
  static var publicTransport: Category {
    let category = Category()
    category.name = "Public transport"
    category.icon = Source.Strings.Categories.Images.publicTransport
    return category
  }
  
  static var other: Category {
    let category = Category()
    category.name = "Other"
    category.icon = Source.Strings.Categories.Images.other
    return category
  }
  
  static var delivery: Category {
    let category = Category()
    category.name = "Delivery"
    category.icon = Source.Strings.Categories.Images.delivery
    return category
  }
  
  static var gaming: Category {
    let category = Category()
    category.name = "Gaming"
    category.icon = Source.Strings.Categories.Images.gaming
    return category
  }
  
  static var animals: Category {
    let category = Category()
    category.name = "Animals"
    category.icon = Source.Strings.Categories.Images.animals
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
    animals
  ]
}
