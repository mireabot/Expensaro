//
//  DefaultCategory.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/21/23.
//

import SwiftUI
import ExpensaroUIKit

struct DefaultCategory: Identifiable {
  var id = UUID().uuidString
  var name: String
  var icon: String
  
  static let defaultSet = [
    DefaultCategory(name: "Clothes", icon: Source.Strings.Categories.Images.clothes),
    DefaultCategory(name: "Education", icon: Source.Strings.Categories.Images.education),
    DefaultCategory(name: "Medical", icon: Source.Strings.Categories.Images.medicine),
    DefaultCategory(name: "Hobby", icon: Source.Strings.Categories.Images.hobby),
    DefaultCategory(name: "Travel", icon: Source.Strings.Categories.Images.travel),
    DefaultCategory(name: "Entertainment", icon: Source.Strings.Categories.Images.entertainment),
    DefaultCategory(name: "Subscription", icon: Source.Strings.Categories.Images.subscriptions),
    DefaultCategory(name: "Going out", icon: Source.Strings.Categories.Images.goingOut),
    DefaultCategory(name: "Groceries", icon: Source.Strings.Categories.Images.groceries),
    DefaultCategory(name: "Utilities", icon: Source.Strings.Categories.Images.utilities),
    DefaultCategory(name: "Shopping", icon: Source.Strings.Categories.Images.shopping),
    DefaultCategory(name: "Car", icon: Source.Strings.Categories.Images.car),
    DefaultCategory(name: "Public transport", icon: Source.Strings.Categories.Images.publicTransport),
    DefaultCategory(name: "Other", icon: Source.Strings.Categories.Images.other),
    DefaultCategory(name: "Delivery", icon: Source.Strings.Categories.Images.delivery),
    DefaultCategory(name: "Gaming", icon: Source.Strings.Categories.Images.gaming),
    DefaultCategory(name: "Animals", icon: Source.Strings.Categories.Images.animals),
  ]
}


private struct DefaultCategoriesList: View {
  var body: some View {
    List {
      ForEach(DefaultCategory.defaultSet) { category in
        EXCategoryCell(icon: Image(category.icon), title: category.name)
      }
    }
  }
}

struct DefaultCategoriesList_Previews: PreviewProvider {
  static var previews: some View {
    DefaultCategoriesList()
  }
}
