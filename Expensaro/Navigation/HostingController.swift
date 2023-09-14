//
//  HostingController.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/10/23.
//

import SwiftUI

/// Wrapper of SwiftUI view to UIHostingController
class CustomHostingController<Content>: UIHostingController<AnyView> where Content: View {
  
  public init(rootView: Content) {
    super.init(rootView: AnyView(rootView))
  }
  
  @objc required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}
