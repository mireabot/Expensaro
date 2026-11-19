//
//  RouterDependencyKey.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import Dependencies

private enum RouterDependencyKey: DependencyKey {
  static let liveValue = Router()
  static var previewValue: Router { Router() }
  static var testValue: Router { Router() }
}

extension DependencyValues {
  var router: Router {
    get { self[RouterDependencyKey.self] }
    set { self[RouterDependencyKey.self] = newValue }
  }
}
