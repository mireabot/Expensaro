//
//  NavigationViewBuilder.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import UIKit
import SwiftUI

final class EXNavigationViewBuilder: NavigationViewBuilder {
  
  static let builder = EXNavigationViewBuilder()
  
  private init() {}
  
  func makeView<T: View>(_ view: T) -> UIViewController {
    CustomHostingController(rootView: view)
  }
}

final class EXNavigationViewsRouter: Router {
  var nav: UINavigationController?
  
  func pushTo(view: UIViewController) {
    nav?.pushViewController(view, animated: true)
  }
  
  func popTo(view: UIViewController) {
    nav?.popToViewController(view, animated: true)
  }
}
