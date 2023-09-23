//
//  Category.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/22/23.
//

import SwiftUI
import CoreData

final class Category: NSManagedObject, Identifiable {
  @NSManaged var icon: String
  @NSManaged var name: String
  
  override func awakeFromInsert() {
    super.awakeFromInsert()
    
    setPrimitiveValue("", forKey: "name")
    setPrimitiveValue("archivebox.fill", forKey: "icon")
  }
  
}

extension Category {
  private static var categoryFetchRequest: NSFetchRequest<Category> {
    NSFetchRequest(entityName: "Category")
  }
  
  static func fetchAll() -> NSFetchRequest<Category> {
    let request: NSFetchRequest<Category> = categoryFetchRequest
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \Category.name, ascending: true)
    ]
    return request
  }
}

extension Category {
  
  @discardableResult
  static func makePreview(in context: NSManagedObjectContext) -> [Category] {
    var categories = [Category]()
    for i in DefaultCategory.defaultSet {
      let category = Category(context: context)
      category.name = i.name
      category.icon = i.icon
      categories.append(category)
    }
    return categories
  }
  
  static func preview(context: NSManagedObjectContext = CategoriesProvider.shared.viewContext) -> [Category] {
    return makePreview(in: context)
  }
  
  static func empty(context: NSManagedObjectContext = CategoriesProvider.shared.viewContext) -> Category {
    return Category(context: context)
  }
}
