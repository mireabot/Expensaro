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
  @Binding var section: String
  
  @State private var showCategory = false
  var body: some View {
    NavigationView {
      VStack {
        Button {
          showCategory.toggle()
        } label: {
          Text("Create new category")
            .font(.system(.subheadline, weight: .medium))
        }
        .buttonStyle(EXStretchButtonStyle(icon: Appearance.shared.addIcon))
        .padding(.top, 20)
        .applyMargins()
        
        List {
          ForEach(Dictionary(grouping: categories, by: { $0.section.header }).keys.sorted(), id: \.self) { sectionHeader in
            Section {
              ForEach(Dictionary(grouping: categories, by: { $0.section.header })[sectionHeader]!) { category in
                EXCategoryCell(icon: Image(category.icon), title: category.name)
                  .onTapGesture {
                    title = category.name
                    icon = category.icon
                    section = category.section.header
                    makeDismiss()
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
      .background(.white)
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showCategory, content: {
        AddCategoryView(isSheet: true, category: Category())
      })
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
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
    CategorySelectorView(title: .constant(""), icon: .constant(""), section: .constant(""))
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}
