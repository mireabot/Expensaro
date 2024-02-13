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
  @Binding var presentation: Bool
  
  @ObservedResults(Category.self, sortDescriptor: SortDescriptor(keyPath: \Category.name, ascending: true)) var categories
  
  @Binding var title: String
  @Binding var icon: String
  @Binding var section: CategoriesSection
  
  @State private var showAddCategory = false
  
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        ForEach(Dictionary(grouping: categories, by: { $0.section.header }).keys.sorted(), id: \.self) { sectionHeader in
          Section {
            ForEach(Dictionary(grouping: categories, by: { $0.section.header })[sectionHeader]!) { category in
              EXCategoryCell(icon: category.icon, title: category.name)
                .onTapGesture {
                  presentation = false
                  title = category.name
                  icon = category.icon
                  section = category.section
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
            .background(Color.white)
            .listRowInsets(EdgeInsets(
              top: 0,
              leading: 0,
              bottom: 0,
              trailing: 0))
          }
        }
      }
      .applyMargins()
      .sheet(isPresented: $showAddCategory, content: {
        AddCategoryView(isSheet: true, category: Category())
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.white, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text(Appearance.shared.title)
            .font(.title3Semibold)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showAddCategory.toggle()
          } label: {
            Appearance.shared.addIcon
              .foregroundColor(.black)
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            presentation = false
          } label: {
            Appearance.shared.closeIcon
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
    ScrollView {
      CategorySelectorView(presentation: .constant(false), title: .constant(""), icon: .constant(""), section: .constant(.other))
        .environment(\.realmConfiguration, RealmMigrator.configuration)
    }
  }
}
