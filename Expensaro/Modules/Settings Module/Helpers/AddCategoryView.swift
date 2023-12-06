//
//  AddCategory.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/21/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift

struct AddCategoryView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @Environment(\.realm) var realm
  @Environment(\.dismiss) var makeDismiss
  @FocusState var isFocused: Bool
  var isSheet: Bool
  
  // MARK: Realm
  @ObservedRealmObject var category: Category
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 15) {
          VStack(alignment: .center, spacing: 15) {
            Image(category.icon)
              .resizable()
              .frame(width: 40, height: 40)
              .foregroundColor(.primaryGreen)
              .padding(8)
              .background(Color.backgroundGrey)
              .cornerRadius(12)
          }
          VStack(alignment: .leading, spacing: 5) {
            Text("Name")
              .foregroundColor(.darkGrey)
              .font(.system(.footnote, weight: .regular))
            EXTextField(text: $category.name, placeholder: "Ex. Metrocard")
              .autocorrectionDisabled()
              .focused($isFocused)
          }
          VStack(alignment: .leading, spacing: 5) {
            LazyHGrid(rows: Appearance.shared.items, alignment: .center, spacing: 20) {
              ForEach(CategoryDescription.allCases, id: \.self) { item in
                Button {
                  withAnimation(.easeOut(duration: 0.5)) {
                    category.icon = item.icon
                  }
                } label: {
                  Image(item.icon)
                    .foregroundColor(category.icon == item.icon ? .white : .primaryGreen)
                    .padding(8)
                    .background(category.icon == item.icon ? Color.primaryGreen : Color.backgroundGrey)
                    .cornerRadius(12)
                }
                .buttonStyle(EXPlainButtonStyle())
              }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.white)
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color.border, lineWidth: 1)
            )
          }
        }
        .padding(.top, 20)
        
      }
      .onAppear {
        category.icon = Source.Strings.Categories.Images.other
      }
      .applyMargins()
      .onTapGesture {
        isFocused = false
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
        }
        ToolbarItem(placement: .navigationBarLeading) {
          if isSheet {
            Button {
              makeDismiss()
            } label: {
              Appearance.shared.closeIcon
                .font(.callout)
                .foregroundColor(.black)
            }
          } else {
            Button {
              router.nav?.popViewController(animated: true)
            } label: {
              Appearance.shared.backIcon
                .font(.callout)
                .foregroundColor(.black)
            }
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            if isSheet {
              saveCategory()
              makeDismiss()
            } else {
              saveCategory()
              router.nav?.popViewController(animated: true)
            }
          } label: {
            Appearance.shared.submitIcon
              .font(.callout)
              .foregroundColor(category.name.isEmpty ? .border : .black)
          }
          .disabled(category.name.isEmpty || category.icon.isEmpty)
        }
      }
    }
  }
}

struct AddCategory_Previews: PreviewProvider {
  static var previews: some View {
    AddCategoryView(isSheet: false, category: Category())
      .environment(\.realmConfiguration, RealmMigrator.configuration)
  }
}

// MARK: - Appearance
extension AddCategoryView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "New category"
    
    let backIcon = Source.Images.Navigation.back
    let closeIcon = Source.Images.Navigation.close
    let submitIcon = Source.Images.Navigation.checkmark
    
    var items: [GridItem] = [
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
    ]
  }
}

// MARK: - Realm Functions
extension AddCategoryView {
  func saveCategory() {
    try? realm.write {
      realm.add(category)
    }
  }
}
