//
//  MonthRecapData.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/24/23.
//

import SwiftUI

// MARK: Sample data for categories breakdown
struct SampleCategoriesBreakdown: Identifiable {
  var id: String = UUID().uuidString
  var categoryName: String
  var categoryIcon: String
  var amount: Double
  var progress: CGFloat
  var progressColor: Color
}

var sampleStorageDetails: [SampleCategoriesBreakdown] = [
  SampleCategoriesBreakdown(categoryName: "Shopping", categoryIcon: "shopping", amount: 600, progress: 0.575, progressColor: .cyan),
  SampleCategoriesBreakdown(categoryName: "Going out", categoryIcon: "goingOut", amount: 100, progress: 0.25, progressColor: .green),
  SampleCategoriesBreakdown(categoryName: "Utilities", categoryIcon: "utilities", amount: 400, progress: 0.25, progressColor: .red),
  SampleCategoriesBreakdown(categoryName: "Bills", categoryIcon: "bills", amount: 1000, progress: 0.625, progressColor: .yellow),
  SampleCategoriesBreakdown(categoryName: "Travel", categoryIcon: "travel", amount: 760, progress: 0.625, progressColor: .blue)
]

