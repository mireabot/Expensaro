//
//  DefaultCategory.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/21/23.
//

import SwiftUI

struct DefaultCategory: Identifiable {
  var id: Int
  var name: String
  var icon: String
  
  static let defaultSet = [
    DefaultCategory(id: 0, name: "Clothes", icon: "tshirt.fill"),
    DefaultCategory(id: 1, name: "Education", icon: "graduationcap.fill"),
    DefaultCategory(id: 2, name: "Medical", icon: "heart.fill"),
    DefaultCategory(id: 3, name: "Hobby", icon: "hammer.fill"),
    DefaultCategory(id: 4, name: "Travel", icon: "airplane"),
    DefaultCategory(id: 5, name: "Entertainment", icon: "ticket.fill"),
    DefaultCategory(id: 6, name: "Subscription", icon: "play.square.stack.fill"),
    DefaultCategory(id: 7, name: "Going out", icon: "takeoutbag.and.cup.and.straw.fill"),
    DefaultCategory(id: 8, name: "Groceries", icon: "bag.fill"),
    DefaultCategory(id: 9, name: "Utilities", icon: "house.fill"),
    DefaultCategory(id: 10, name: "Shopping", icon: "cart.fill"),
    DefaultCategory(id: 11, name: "Car", icon: "car.side.fill"),
    DefaultCategory(id: 12, name: "Public transport", icon: "cablecar.fill"),
    DefaultCategory(id: 13, name: "Other", icon: "archivebox.fill"),
  ]
}
