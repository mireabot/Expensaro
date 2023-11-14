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


//MARK: Default goals data for previews
enum DefaultGoals {
  static var goal1: Goal {
    let goal = Goal()
    goal.name = "Vacation Fund"
    goal.finalAmount = 1000
    goal.currentAmount = 500
    goal.dueDate = Date().addingTimeInterval(60 * 60 * 24 * 90)
    return goal
  }
  
  static var goal2: Goal {
    let goal = Goal()
    goal.name = "New Laptop"
    goal.finalAmount = 1500
    goal.currentAmount = 1500
    goal.dueDate = Date().addingTimeInterval(60 * 60 * 24 * 90)
    return goal
  }
  
  static var goal3: Goal {
    let goal = Goal()
    goal.name = "Failed Goal"
    goal.finalAmount = 1500
    goal.currentAmount = 100
    goal.dueDate = Date().addingTimeInterval(-60 * 60 * 24 * 30)
    return goal
  }
  
  static let defaultGoals = [
    goal1,
    goal2,
    goal3
  ]
}

// MARK: Computed properties for goal
extension Goal {
  var daysLeft: Int {
    let calendar = Calendar.current
    let currentDate = Source.Functions.localDate(with: .now)
    let components = calendar.dateComponents([.day], from: currentDate, to: Source.Functions.localDate(with: dueDate))
    return components.day ?? 0
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
