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
  
  // MARK: Presentation
  @State private var showSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 15) {
          VStack(alignment: .center, spacing: 15) {
            Image(category.icon)
              .resizable()
              .frame(width: 50, height: 50)
              .foregroundColor(.primaryGreen)
              .padding(8)
          }
          
          EXTextField(text: $category.name, header: "Category name", placeholder: "Ex. Metrocard")
            .autocorrectionDisabled()
            .focused($isFocused)
          
          Button(action: {
            showSelector.toggle()
          }, label: {
            EXLargeSelector(text: .constant(category.section.header), icon: .constant(""), header: "Category header", rightIcon: "swipeDown")
          })
          .buttonStyle(EXPlainButtonStyle())
          
          EXBaseCard {
            LazyVGrid(columns: Appearance.shared.items, alignment: .center) {
              ForEach(CategoryDescription.allCases, id: \.self) { item in
                Button {
                  withAnimation(.easeOut(duration: 0.5)) {
                    category.icon = item.icon
                  }
                } label: {
                  Image(item.icon)
                    .foregroundColor(category.icon == item.icon ? .white : .primaryGreen)
                    .padding(8)
                    .background(category.icon == item.icon ? Color.primaryGreen : Color.clear)
                    .cornerRadius(12)
                }
                .buttonStyle(EXPlainButtonStyle())
              }
            }
          }
        }
        .padding(.top, 20)
        
      }
      .applyMargins()
      .onTapGesture {
        isFocused = false
      }
      .sheet(isPresented: $showSelector, content: {
        selectorView()
          .presentationDetents([.fraction(0.5)])
      })
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
  
  @ViewBuilder
  func selectorView() -> some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        ForEach(CategoriesSection.allCases, id: \.header) { folder in
          Button(action: {
            category.section = folder
            showSelector.toggle()
          }, label: {
            EXBaseCard {
              Text(folder.rawValue.capitalized)
                .font(.bodyMedium)
                .frame(maxWidth: .infinity)
            }
          })
          .buttonStyle(EXPlainButtonStyle())
        }
      }
      .applyMargins()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Select category header")
            .font(.system(.headline, weight: .medium))
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showSelector.toggle()
          } label: {
            Source.Images.Navigation.close
              .foregroundColor(.black)
          }
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
      GridItem(.flexible(), spacing: 15),
    ]
  }
}

// MARK: - Realm Functions
extension AddCategoryView {
  func saveCategory() {
    category.tag = .custom
    try? realm.write {
      realm.add(category)
    }
  }
}
