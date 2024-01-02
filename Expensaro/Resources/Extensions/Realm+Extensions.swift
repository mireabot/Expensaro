//
//  Realm+Extensions.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 12/28/23.
//

import SwiftUI
import RealmSwift

extension Results {
  func toArray<T>(ofType: T.Type) -> [T] {
    var array = [T]()
    for i in 0 ..< count {
      if let result = self[i] as? T {
        array.append(result)
      }
    }
    
    return array
  }
}
