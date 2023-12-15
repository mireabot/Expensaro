//
//  TopCategories.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/14/23.
//

import SwiftUI

struct TopCategories: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

let topCategoriesData: [TopCategories] = [
  TopCategories(name: "Groceries", amount: 800),
  TopCategories(name: "Entertainment", amount: 500),
  TopCategories(name: "Bills", amount: 700),
  TopCategories(name: "Subscriptions", amount: 350)
]
