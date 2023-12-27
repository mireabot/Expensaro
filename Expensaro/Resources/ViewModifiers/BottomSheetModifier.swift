//
//  BottomSheetModifier.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/14/23.
//

import SwiftUI
import PartialSheet
import RealmSwift

struct ListExample: View {
  @State private var isSheetPresented = false
  @State private var selectedIndex: Int = 0
  let animationIn: Animation = .spring
  
  var body: some View {
    Button {
      withAnimation(animationIn) {
        isSheetPresented.toggle()
      }
    } label: {
      Text("Show")
    }
    .partialSheet(isPresented: $isSheetPresented, type: .scrollView(height: 500, showsIndicators: false)) {
      CategorySelectorView(presentation: $isSheetPresented, title: .constant(""), icon: .constant(""), section: .constant(""))
        .environment(\.realmConfiguration, RealmMigrator.configuration)
    }
    .navigationBarTitle(Text("List Example"))
  }
}

struct ListExample_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ListExample()
    }
    .attachPartialSheetToRoot()
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
