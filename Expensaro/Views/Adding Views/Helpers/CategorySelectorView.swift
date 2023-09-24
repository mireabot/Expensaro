//
//  CategorySelectorView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/24/23.
//

import SwiftUI
import ExpensaroUIKit

struct CategorySelectorView: View {
  @Environment(\.dismiss) var makeDismiss
  var provider = CategoriesProvider.shared
  @FetchRequest(fetchRequest: Category.fetchAll()) private var categories
  let items: [GridItem] = [
    GridItem(.flexible(), spacing: 20),
    GridItem(.flexible(), spacing: 20),
  ]
  @Binding var title: String
  @Binding var icon: Image
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        LazyVGrid(columns: items) {
          ForEach(categories) { category in
            EXCategoryCell(icon: Image(systemName: category.icon), title: category.name)
              .onTapGesture {
                title = category.name
                icon = Image(systemName: category.icon)
                makeDismiss()
              }
          }
        }
        .applyMargins()
      }
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
