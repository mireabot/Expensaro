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
            emptyState()
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


// MARK: - Helper Views
extension CategoriesSettingsView {
  @ViewBuilder
  func emptyState() -> some View {
    VStack(alignment: .center, spacing: 3) {
      Text("You haven't created own categories yet")
        .font(.mukta(.semibold, size: 15))
        .multilineTextAlignment(.center)
      Text("Click the button on the top to create one")
        .font(.mukta(.regular, size: 13))
        .foregroundColor(.darkGrey)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity)
    .background(Color.backgroundGrey)
    .cornerRadius(12)
  }
}
