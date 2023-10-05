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
    let preview = CategoriesProvider.shared
    CategorySelectorView(provider: preview, title: .constant("Travel"), icon: .constant(.init(systemName: "globe")))
      .environment(\.managedObjectContext, preview.viewContext)
      .onAppear { Category.makePreview(in: preview.viewContext) }
  }
}
