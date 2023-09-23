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
      ScrollView {
        Button {
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(AddCategoryView(categoryVM: .init(provider: provider))))
        } label: {
          Text("Create new category")
            .font(.mukta(.regular, size: 17))
        }
        .buttonStyle(StretchButtonStyle(icon: Appearance.shared.addIcon))
        .padding(.top, 20)
        .applyMargins()
        
        customCategoriesList()
          .padding(.vertical, 15)
        
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
    CategoriesSettingsView()
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
  
  @ViewBuilder
  func customCategoriesList() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("All categories")
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
        .frame(maxWidth: .infinity, alignment: .leading)
      if categories.isEmpty {
        Text("You haven't created any category")
          .font(.mukta(.medium, size: 15))
          .frame(maxWidth: .infinity, alignment: .center)
      } else {
        VStack(spacing: 10) {
          ForEach(categories) { category in
            HStack {
              EXCategoryListCell(icon: Image(systemName: category.icon), title: category.name)
              Button {
                do {
                  try provider.delete(category,
                                      in: provider.newContext)
                } catch {
                  print(error.localizedDescription)
                }
              } label: {
                Source.Images.Navigation.close
                  .font(.body)
                  .foregroundColor(.red)
              }
            }
          }
        }
      }
    }
    .applyMargins()
  }
}
