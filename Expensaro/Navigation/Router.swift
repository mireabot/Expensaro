//
//  Router.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import UIKit
import Combine
import SwiftUI

/// Types of navigation for router
protocol Router: ObservableObject {
  var nav: UINavigationController? { get set }
  func pushTo(view: UIViewController)
  func popTo(view: UIViewController)
  func popToRoot()
}


extension Router {
  func popToRoot() {
    nav?.popToRootViewController(animated: true)
  }
}


/// Wrapper of SwiftUI view to UIViewController
protocol NavigationViewBuilder {
    func makeView<T: View>(_ view: T) -> UIViewController
}
