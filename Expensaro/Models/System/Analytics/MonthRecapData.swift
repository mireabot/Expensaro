//
//  MonthRecapData.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/24/23.
//

import SwiftUI

// MARK: Sample data for categories breakdown
struct SampleCategoriesBreakdown: Identifiable {
  var id = UUID()
  var categoryName: CategoriesSection
  var amount: Double
  var progressColor: Color
}

var sampleStorageDetails: [SampleCategoriesBreakdown] = [
  SampleCategoriesBreakdown(categoryName: .entertainment, amount: 600, progressColor: Color(red: 0.612, green: 0.22, blue: 0.282)),
  SampleCategoriesBreakdown(categoryName: .food, amount: 100, progressColor: Color(red: 1, green: 0.678, blue: 0.412)),
  SampleCategoriesBreakdown(categoryName: .other, amount: 400, progressColor: Color(red: 0.961, green: 0.902, blue: 0.388)),
  SampleCategoriesBreakdown(categoryName: .transportation, amount: 1000, progressColor: Color(red: 0.278, green: 0.659, blue: 0.741)),
  SampleCategoriesBreakdown(categoryName: .lifestyle, amount: 760, progressColor: Color(red: 0.118, green: 0.22, blue: 0.533))
]

