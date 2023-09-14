//
//  RootNavigationController.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI

/// Reusable Navigation Controller to be used as the root controller
struct RootNavigationController<RootView: View>: UIViewControllerRepresentable {
  
  let nav: UINavigationController
  let rootView: RootView
  
  init(nav: UINavigationController, rootView: RootView) {
    self.nav = nav
    self.rootView = rootView
  }
  
  func makeUIViewController(context: Context) -> UINavigationController {
    let vc = CustomHostingController(rootView: rootView)
    nav.navigationBar.isHidden = true
    nav.navigationBar.isTranslucent = false
    nav.addChild(vc)
    return nav
  }
  
  func updateUIViewController(_ pageViewController: UINavigationController, context: Context) {
  }
  
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
