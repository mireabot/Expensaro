//
//  CategoryDataProvider.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/22/23.
//

import SwiftUI
import CoreData

final class CategoriesProvider {
  static let shared = CategoriesProvider()
  
  private let persistentContainer: NSPersistentContainer
  
  var viewContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  var newContext: NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
    return context
  }
  
  private init() {
    persistentContainer = NSPersistentContainer(name: "Expensaro")
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.loadPersistentStores { _, error in
      if let error {
        fatalError("\(error)")
      }
    }
  }
  
  func exisits(_ category: Category,
               in context: NSManagedObjectContext) -> Category? {
    try? context.existingObject(with: category.objectID) as? Category
  }
  
  func delete(_ category: Category,
              in context: NSManagedObjectContext) throws {
    if let existingCategory = exisits(category, in: context) {
      context.delete(existingCategory)
      Task(priority: .background) {
        try await context.perform {
          try context.save()
        }
      }
    }
  }
}


final class CategoryStore: ObservableObject {
  @Published var newCategory: Category
  private let context: NSManagedObjectContext
  
  init(provider: CategoriesProvider, category: Category? = nil) {
    self.context = provider.newContext
    self.newCategory = Category(context: self.context)
  }
  
  func saveCategory() throws {
    if context.hasChanges {
      try context.save()
    }
  }
  
  func loadCategories(in context: NSManagedObjectContext) throws {
    var categories = [Category]()
    for i in DefaultCategory.defaultSet {
      let contact = Category(context: context)
      contact.icon = i.icon
      contact.name = i.name
      categories.append(contact)
    }
    try context.save()
  }
}
