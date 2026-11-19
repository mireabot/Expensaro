//
//  OverviewRootView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI
import Dependencies

struct OverviewRootView: View {
  @State private var router: Router

  init() {
    @Dependency(\.router) var shared
    _router = State(initialValue: shared)
  }

  var body: some View {
    NavigationStack(path: router.path(for: .overview)) {
      OverviewView()
        .withAppRouter()
    }
  }
}
