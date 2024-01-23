//
//  Goal.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import Foundation
import ExpensaroUIKit
import RealmSwift
import SwiftUI

final class Goal: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var finalAmount: Double
  @Persisted var currentAmount: Double
  @Persisted var dueDate: Date
  @Persisted var dateCreated: Date
  
  @Persisted var transactions: RealmSwift.List<GoalTransaction> = RealmSwift.List<GoalTransaction>()
}

class GoalTransaction: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var amount: Double
  @Persisted var note: String = ""
  @Persisted var date: Date = Date()
  
  @Persisted(originProperty: "transactions") var goal: LinkingObjects<Goal>
}

// MARK: Computed properties for goal
extension Goal {
  var daysLeft: Int {
    let calendar = Calendar.current
    let fromDate = calendar.startOfDay(for: Date())
    let toDate = calendar.startOfDay(for: dueDate)
    let numberOfDays = calendar.dateComponents([.day], from: fromDate, to: toDate)
    
    return numberOfDays.day!
  }
  
  var amountLeft: Double {
    return finalAmount - currentAmount
  }
  
  var isCompleted: Bool {
    return currentAmount >= finalAmount
  }
  
  var isFailed: Bool {
    return currentAmount < finalAmount && Source.Functions.localDate(with: .now) >= Source.Functions.localDate(with: dueDate)
  }
  
  var goalTitle: String {
    if isCompleted {
      return "Congrats! You reached your goal"
    }
    if isFailed {
      return "Sorry to see, but you failed to collect full amount"
    }
    else {
      return ""
    }
  }
  
  var barTint: Color {
    if isCompleted {
      return .green
    }
    if isFailed {
      return .red
    }
    else {
      return .primaryGreen
    }
  }
}
