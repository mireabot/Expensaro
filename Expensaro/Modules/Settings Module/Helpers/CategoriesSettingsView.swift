//
//  CategoriesSettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/22/23.
//

import SwiftUI
import Dependencies
import ExpensaroUIKit
import SwiftData

struct CategoriesSettingsView: View {
  @Dependency(\.router) private var router
  
  @Query(Category.byName) private var categories: [Category]
  var body: some View {
    VStack {
      Button {
        router.navigate(to: .addCategory)
      } label: {
        Text("Create new category")
          .font(.subheadlineMedium)
      }
      .buttonStyle(EXStretchButtonStyle(icon: Appearance.shared.addIcon))
      .padding(.top, 20)
      .applyMargins()
      
      List {
        ForEach(Dictionary(grouping: categories, by: { $0.section.header }).keys.sorted(), id: \.self) { sectionHeader in
          Section {
            ForEach(Dictionary(grouping: categories, by: { $0.section.header })[sectionHeader]!) { category in
              EXCategoryCell(icon: category.icon, title: category.name)
                .swipeActions {
                  Button("Delete", role: .destructive, action: {
                    deleteCategory(category: category)
                  })
                }
            }
            .listRowSeparator(.hidden)
          } header: {
            HStack {
              Text(sectionHeader)
                .font(.footnoteRegular)
                .foregroundColor(.darkGrey)
                .padding(5)
              Spacer()
            }
            .applyMargins()
            .background(Color.white)
            .listRowInsets(EdgeInsets(
              top: 0,
              leading: 0,
              bottom: 0,
              trailing: 0))
          }
        }
      }
      .listStyle(.plain)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(Appearance.shared.title)
          .font(.system(.headline, weight: .medium))
      }
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          router.back()
        } label: {
          Appearance.shared.backIcon
            .font(.callout)
            .foregroundColor(.black)
        }
      }
    }
  }
}

struct CategoriesSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    CategoriesSettingsView()
      .modelContainer(AppModelStore.preview)
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

// MARK: - Storage Functions
extension CategoriesSettingsView {
  func deleteCategory(category: Category) {
    try? category.delete()
  }
}
