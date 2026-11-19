//
//  Budget.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/11/23.
//

import SwiftUI
import SwiftData

extension ExpensaroSchemaV1 {
  @Model
  final class Budget {
    @Attribute(.unique) var id: String = UUID().uuidString
    var amount: Double = 0
    var initialAmount: Double = 0
    var dateCreated: Date = Date()

    init() {}
  }
}
