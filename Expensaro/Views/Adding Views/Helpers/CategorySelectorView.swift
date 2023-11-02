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
  
  @ObservedResults(Category.self, sortDescriptor: SortDescriptor(keyPath: \Category.name, ascending: true)) var categories
  
  @Binding var title: String
  @Binding var icon: String
  
  @State private var showCategory = false
  var body: some View {
    NavigationView {
      List {
        VStack {
          Button {
            showCategory.toggle()
          } label: {
            Text("Create new category")
              .font(.mukta(.regular, size: 17))
          }
          .buttonStyle(StretchButtonStyle(icon: Appearance.shared.addIcon))
        }
        .listRowSeparator(.hidden)
        
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
              .onTapGesture {
                title = category.name
                icon = category.icon
                makeDismiss()
              }
          }
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
            .onTapGesture {
              title = category.name
              icon = category.icon
              makeDismiss()
            }
        }
        .listRowSeparator(.hidden)
        
      }
      .listStyle(.plain)
      .background(.white)
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showCategory, content: {
        AddCategoryView(isSheet: true, category: Category())
      })
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
    let addIcon = Source.Images.ButtonIcons.add
  }
}

struct CategorySelectorView_Previews: PreviewProvider {
  static var previews: some View {
    CategorySelectorView(title: .constant(""), icon: .constant(""))
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Helper Views
extension CategorySelectorView {
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
