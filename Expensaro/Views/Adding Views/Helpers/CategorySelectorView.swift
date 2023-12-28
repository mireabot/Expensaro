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
  @Binding var section: String
  
  @State private var showCategory = false
  
  let loadedCategories: [Category] = [
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.subscriptions, name: "Subscription", tag: .base, section: .entertainment),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.entertainment, name: "Entertainment", tag: .base, section: .entertainment),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.hobby, name: "Hobby", tag: .base, section: .entertainment),
    
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.goingOut, name: "Going out", tag: .base, section: .food),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.groceries, name: "Groceries", tag: .base, section: .food),
    
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.bills, name: "Bills", tag: .base, section: .housing),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.utilities, name: "Utilities", tag: .base, section: .housing),
    
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.publicTransport, name: "Public transport", tag: .base, section: .transportation),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.car, name: "Car", tag: .base, section: .transportation),
    
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.education, name: "Education", tag: .base, section: .lifestyle),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.travel, name: "Travel", tag: .base, section: .lifestyle),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.shopping, name: "Shopping", tag: .base, section: .lifestyle),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.delivery, name: "Delivery", tag: .base, section: .lifestyle),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.gaming, name: "Gaming", tag: .base, section: .lifestyle),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.animals, name: "Animals", tag: .base, section: .lifestyle),
    
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.clothes, name: "Clothes", tag: .base, section: .other),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.other, name: "Other", tag: .base, section: .other),
    Source.Realm.createCategory(icon: Source.Strings.Categories.Images.medicine, name: "Healthcare", tag: .base, section: .other),
  ]
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        ForEach(Dictionary(grouping: categories, by: { $0.section.header }).keys.sorted(), id: \.self) { sectionHeader in
          Section {
            ForEach(Dictionary(grouping: categories, by: { $0.section.header })[sectionHeader]!) { category in
              EXCategoryCell(icon: Image(category.icon), title: category.name)
                .onTapGesture {
                  presentation = false
                  title = category.name
                  icon = category.icon
                  section = category.section.header
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.white, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text(Appearance.shared.title)
            .font(.title3Semibold)
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
      CategorySelectorView(presentation: .constant(false), title: .constant(""), icon: .constant(""), section: .constant(""))
        .environment(\.realmConfiguration, RealmMigrator.configuration)
    }
  }
}
