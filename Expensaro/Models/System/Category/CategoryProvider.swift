//
//  CategoryProvider.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/19/23.
//

import Foundation
import CoreData

class CategoryProvider {
  static let shared = CategoryProvider()
  
  private init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Category")
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  var managedObjectContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  func saveCategory(name: String, icon: String) {
    let context = managedObjectContext
    let newCategory = Category(context: context)
    newCategory.name = name
    newCategory.icon = icon
    
    do {
      try context.save()
    } catch {
      print("Error saving category: \(error.localizedDescription)")
    }
  }
}

@objc(Category)
public class Category: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var icon: String
}
