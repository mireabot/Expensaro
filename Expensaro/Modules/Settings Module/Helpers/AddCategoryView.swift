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
  @Environment(\.realm) var realm
  @Environment(\.dismiss) var makeDismiss
  
  @ObservedRealmObject var category: Category
  
  @EnvironmentObject var router: EXNavigationViewsRouter
  @FocusState var isFocused: Bool
  @State private var changeIcon = false
  @State var detentHeight: CGFloat = 0
  let items: [GridItem] = [
    GridItem(.fixed(40), spacing: 20),
    GridItem(.fixed(40), spacing: 20),
    GridItem(.fixed(40), spacing: 20),
  ]
  var isSheet: Bool
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(alignment: .center, spacing: 15) {
            if category.icon.isEmpty {
              Image(Source.Strings.Categories.Images.other)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.primaryGreen)
            } else {
              Image(category.icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.primaryGreen)
            }
            
            Button {
              changeIcon.toggle()
            } label: {
              Text("Change")
                .font(.mukta(.semibold, size: 13))
            }
            .buttonStyle(SmallButtonStyle())
          }
          VStack(alignment: .leading, spacing: 5) {
            Text("Name")
              .foregroundColor(.darkGrey)
              .font(.mukta(.regular, size: 13))
            EXTextField(text: $category.name, placeholder: "Required")
              .keyboardType(.alphabet)
              .focused($isFocused)
          }
        }
        .padding(.top, 20)
        
      }
      .applyMargins()
      .onTapGesture {
        isFocused = false
      }
      .sheet(isPresented: $changeIcon, content: {
        iconsGrid()
          .readHeight()
          .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
              self.detentHeight = height
            }
          }
          .presentationDetents([.height(self.detentHeight)])
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
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
          .disabled(category.name.isEmpty)
        }
      }
    }
  }
}

struct AddCategory_Previews: PreviewProvider {
  static var previews: some View {
    AddCategoryView(category: Category(), isSheet: false)
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
  }
}

// MARK: - Helper Views
extension AddCategoryView {
  @ViewBuilder
  func iconsGrid() -> some View {
    VStack(spacing: 0) {
      Button {
        changeIcon.toggle()
      } label: {
        Source.Images.Navigation.checkmark
          .font(.callout)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .applyMargins()
          .padding(.vertical, 10)
      }

      Divider()
      
      LazyHGrid(rows: items, alignment: .center, spacing: 20) {
        ForEach(DefaultCategories.defaultCategories) { item in
          Image(item.icon)
            .foregroundColor(.primaryGreen)
            .padding(8)
            .background(Color.backgroundGrey)
            .cornerRadius(12)
            .onTapGesture {
              category.icon = item.icon
              changeIcon.toggle()
            }
        }
      }
      .applyMargins()
      .padding(.vertical, 15)
    }
  }
}

// MARK: - Realm Functions
extension AddCategoryView {
  func saveCategory() {
    try? realm.write {
      realm.add(category)
    }
    router.nav?.popViewController(animated: true)
  }
}
