//
//  RecurrentPayment.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/1/23.
//

import SwiftUI

struct RecurrentPayment: Identifiable {
  var id = UUID().uuidString
  var name: String
  var amount: Float
  var currentValue: CGFloat
  var maxValue: CGFloat
  var dueDate: Date
  
  static let recurrentPayments: [RecurrentPayment] = [
    RecurrentPayment(name: "Netflix", amount: 12.99, currentValue: 15, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
    RecurrentPayment(name: "Amazon Prime", amount: 9.99, currentValue: 5, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()),
    RecurrentPayment(name: "Hulu", amount: 7.99, currentValue: 25, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()),
    RecurrentPayment(name: "Apple Music", amount: 9.99, currentValue: 20, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()),
    RecurrentPayment(name: "Disney+", amount: 7.99, currentValue: 12, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date()),
    RecurrentPayment(name: "Gym Membership", amount: 29.99, currentValue: 2, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()),
    RecurrentPayment(name: "Electricity Bill", amount: 50.0, currentValue: 28, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()),
    RecurrentPayment(name: "Water Bill", amount: 20.0, currentValue: 3, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
    RecurrentPayment(name: "Internet", amount: 45.0, currentValue: 30, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
    RecurrentPayment(name: "Cell Phone", amount: 40.0, currentValue: 18, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date())
  ]
}

struct RecurrentPaymentData: Identifiable{
    var id = UUID().uuidString
    var payments: [RecurrentPayment]
    var paymentDueDate: Date
}

var sampleRecurrentPayments : [RecurrentPaymentData] = [
  RecurrentPaymentData(payments: [
    RecurrentPayment(name: "Netflix", amount: 12.99, currentValue: 15, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
    RecurrentPayment(name: "Amazon Prime", amount: 9.99, currentValue: 5, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
    RecurrentPayment(name: "Hulu", amount: 7.99, currentValue: 25, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
    RecurrentPayment(name: "Apple Music", amount: 9.99, currentValue: 20, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
    RecurrentPayment(name: "Disney+", amount: 7.99, currentValue: 12, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())
  ], paymentDueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
  
  RecurrentPaymentData(payments: [
    RecurrentPayment(name: "Gym Membership", amount: 29.99, currentValue: 2, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
    RecurrentPayment(name: "Electricity Bill", amount: 50.0, currentValue: 28, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
    RecurrentPayment(name: "Water Bill", amount: 20.0, currentValue: 3, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
    RecurrentPayment(name: "Internet", amount: 45.0, currentValue: 30, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
    RecurrentPayment(name: "Cell Phone", amount: 40.0, currentValue: 18, maxValue: 30, dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date())
  ], paymentDueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date()),
]
