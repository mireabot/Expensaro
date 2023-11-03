//
//  CategoriesSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/22/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct CategoriesSettingsView: View {
  @Environment(\.realm) var realm
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  @ObservedResults(Category.self, sortDescriptor: SortDescriptor(keyPath: \Category.name, ascending: true)) var categories
  var body: some View {
    NavigationView {
      VStack {
        Button {
          router.pushTo(view: EXNavigationViewBuilder.builder.makeView(AddCategoryView(isSheet: false, category: Category())))
        } label: {
          Text("Create new category")
            .font(.mukta(.regular, size: 17))
        }
        .buttonStyle(StretchButtonStyle(icon: Appearance.shared.addIcon))
        .padding(.top, 20)
        .applyMargins()
        
        List {
          Section {
            Text("Custom categories")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .listRowSeparator(.hidden)
          if categories.isEmpty {
            EXEmptyStateView(type: .noCustomCategories)
              .listRowSeparator(.hidden)
          } else {
            ForEach(categories) { category in
              EXCategoryCell(icon: Image(category.icon), title: category.name)
            }
            .onDelete(perform: $categories.remove)
            .listRowSeparator(.hidden)
          }
          
          Section {
            Text("Default categories")
              .font(.mukta(.regular, size: 13))
              .foregroundColor(.darkGrey)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .listRowSeparator(.hidden)
          ForEach(CategoryDescription.allCases.sorted { $0.rawValue < $1.rawValue }, id: \.self) { category in
            EXCategoryCell(icon: Image(category.icon), title: category.name)
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
    CategoriesSettingsView()
      .environment(\.realmConfiguration, RealmMigrator.configuration)
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
