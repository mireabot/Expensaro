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
          
          ForEach(categories) { category in
            EXCategoryCell(icon: Image(category.icon), title: category.name)
              .onTapGesture {
                title = category.name
                icon = category.icon
                makeDismiss()
              }
          }
        }
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
      .background(.white)
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showCategory, content: {
        AddCategoryView(category: Category(), isSheet: true)
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
