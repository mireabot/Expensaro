//
//  CategoryDescription.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/2/23.
//

import SwiftUI

/// Enum with details about default categories
enum CategoryDescription {
  case clothes
  case education
  case medicine
  case hobby
  case travel
  case entertainment
  case subscriptions
  case goingOut
  case groceries
  case utilities
  case shopping
  case car
  case publicTransport
  case other
  case delivery
  case gaming
  case animals
  case bills
  
  var name: String {
    switch self {
    case .clothes:
      return "Clothes"
    case .education:
      return "Education"
    case .medicine:
      return "Medical"
    case .hobby:
      return "Hobby"
    case .travel:
      return "Travel"
    case .entertainment:
      return "Entertainment"
    case .subscriptions:
      return "Subscription"
    case .goingOut:
      return "Going out"
    case .groceries:
      return "Groceries"
    case .utilities:
      return "Utilities"
    case .shopping:
      return "Shopping"
    case .car:
      return "Car"
    case .publicTransport:
      return "Public transport"
    case .other:
      return "Other"
    case .delivery:
      return "Delivery"
    case .gaming:
      return "Gaming"
    case .animals:
      return "Animals"
    case .bills:
      return "Bills"
    }
  }
  
  var icon: String {
    switch self {
    case .clothes:
      Source.Strings.Categories.Images.clothes
    case .education:
      Source.Strings.Categories.Images.education
    case .medicine:
      Source.Strings.Categories.Images.medicine
    case .hobby:
      Source.Strings.Categories.Images.hobby
    case .travel:
      Source.Strings.Categories.Images.travel
    case .entertainment:
      Source.Strings.Categories.Images.entertainment
    case .subscriptions:
      Source.Strings.Categories.Images.subscriptions
    case .goingOut:
      Source.Strings.Categories.Images.goingOut
    case .groceries:
      Source.Strings.Categories.Images.groceries
    case .utilities:
      Source.Strings.Categories.Images.utilities
    case .shopping:
      Source.Strings.Categories.Images.shopping
    case .car:
      Source.Strings.Categories.Images.car
    case .publicTransport:
      Source.Strings.Categories.Images.publicTransport
    case .other:
      Source.Strings.Categories.Images.other
    case .delivery:
      Source.Strings.Categories.Images.delivery
    case .gaming:
      Source.Strings.Categories.Images.gaming
    case .animals:
      Source.Strings.Categories.Images.animals
    case .bills:
      Source.Strings.Categories.Images.bills
    }
  }
}
