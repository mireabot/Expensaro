//
//  CategorySelectorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/24/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct CategorySelectorView: View {
  @Environment(\.dismiss) var makeDismiss
  
  @ObservedResults(Category.self) var categories
  
  @Binding var title: String
  @Binding var icon: Image
  var body: some View {
    NavigationView {
      List {
        VStack {
          ForEach(categories) { category in
            EXCategoryCell(icon: Image(category.icon), title: category.name)
              .onTapGesture {
                title = category.name
                icon = Image(category.icon)
                makeDismiss()
              }
          }
        }
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
      .background(.white)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            makeDismiss()
          } label: {
            Appearance.shared.closeIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

//MARK: - Appearance
extension CategorySelectorView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Select category"
    
    let closeIcon = Source.Images.Navigation.close
  }
}

struct CategorySelectorView_Previews: PreviewProvider {
  static var previews: some View {
    EmptyView()
  }
}
