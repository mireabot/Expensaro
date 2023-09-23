//
//  CategoriesSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/22/23.
//

import SwiftUI
import ExpensaroUIKit

struct CategoriesSettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  var provider = CategoriesProvider.shared
  @FetchRequest(fetchRequest: Category.fetchAll()) private var categories
  var body: some View {
    NavigationView {
      VStack {
        Button {
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(AddCategoryView(categoryVM: .init(provider: provider))))
        } label: {
          Text("Create new category")
            .font(.mukta(.regular, size: 17))
        }
        .buttonStyle(StretchButtonStyle(icon: Appearance.shared.addIcon))
        .padding(.top, 20)
        .applyMargins()
        
        Text("All categories")
          .font(.mukta(.regular, size: 13))
          .foregroundColor(.darkGrey)
          .frame(maxWidth: .infinity, alignment: .leading)
          .applyMargins()
        
        List {
          ForEach(categories) { category in
            EXCategoryListCell(icon: Image(systemName: category.icon), title: category.name)
              .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                  do {
                    try provider.delete(category, in: provider.newContext)
                  } catch {
                    print(error.localizedDescription)
                  }
                } label: {
                  Label("Delete", systemImage: "trash")
                }
                .tint(.primaryGreen)
              }
          }
          .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
      }
    }
  }
}

struct CategoriesSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    let preview = CategoriesProvider.shared
    CategoriesSettingsView(provider: preview)
      .environment(\.managedObjectContext, preview.viewContext)
      .onAppear { Category.makePreview(in: preview.viewContext) }
  }
}

// MARK: - Appearance
extension CategoriesSettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Manage categories"
    
    let backIcon = Source.Images.Navigation.back
    let addIcon = Source.Images.ButtonIcons.add
  }
}

extension CategoriesSettingsView {
  @ViewBuilder
  func defaultCategoriesList() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Default categories")
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
        .frame(maxWidth: .infinity, alignment: .leading)
      VStack(spacing: 10) {
        ForEach(DefaultCategory.defaultSet) { category in
          EXCategoryListCell(icon: Image(systemName: category.icon), title: category.name)
        }
      }
    }
    .applyMargins()
  }
}
