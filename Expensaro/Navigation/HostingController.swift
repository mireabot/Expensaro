//
//  HostingController.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI

/// Wrapper of SwiftUI view to UIHostingController
class CustomHostingController<Content>: UIHostingController<AnyView> where Content: View {
  
  // Each tab root and pushed screen is its own hosting controller, so the app-root environment
  // never reaches it; the shared container is injected here for every hosted screen.
  public init(rootView: Content) {
    super.init(rootView: AnyView(rootView.modelContainer(AppModelStore.container)))
  }
  
  @objc required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}
