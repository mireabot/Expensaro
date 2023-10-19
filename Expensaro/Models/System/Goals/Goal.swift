//
//  Goal.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import Foundation
import ExpensaroUIKit
import RealmSwift

final class Goal: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var id: ObjectId
  @Persisted var name: String
  @Persisted var finalAmount: Double
  @Persisted var currentAmount: Double
  @Persisted var dueDate: Date
  
  @Persisted var transactions: List<GoalTransaction> = List<GoalTransaction>()
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
