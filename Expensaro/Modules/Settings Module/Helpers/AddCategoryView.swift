//
//  AddCategory.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/21/23.
//

import SwiftUI
import ExpensaroUIKit
import RealmSwift
import UIKit

struct AddCategoryView: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  @Environment(\.realm) var realm
  @Environment(\.dismiss) var makeDismiss
  @FocusState var isFocused: Bool
  var isSheet: Bool
  
  // MARK: Realm
  @ObservedRealmObject var category: Category
  
  // MARK: Variables
  @State private var sheetHeight: CGFloat = .zero
  
  // MARK: Presentation
  @State private var showSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 15) {
          EXEmojiKeyboard(text: $category.icon)
            .focused($isFocused)
            .padding(12)
          
          EXTextField(text: $category.name, header: "Category name", placeholder: "Ex. Metrocard")
            .autocorrectionDisabled()
            .focused($isFocused)
          
          Button(action: {
            showSelector.toggle()
          }, label: {
            EXLargeSelector(text: .constant(category.section.header), icon: .constant(.imageName("")), header: "Category section", rightIcon: "swipeDown")
          })
          .buttonStyle(EXPlainButtonStyle())
        }
        .padding(.top, 20)
        
      }
      .applyMargins()
      .onTapGesture {
        isFocused = false
      }
      .sheet(isPresented: $showSelector, content: {
        selectorView()
          .modifier(GetHeightModifier(height: $sheetHeight))
          .presentationDetents([.height(sheetHeight)])
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
    ViewThatFits(in: .vertical) {
      VStack {
        HStack {
          Text("Select category section")
            .font(.title3Bold)
          Spacer()
          Button {
            showSelector.toggle()
          } label: {
            Source.Images.Navigation.close
              .foregroundColor(.black)
          }
        }
        .padding(.vertical, 20)
        ForEach(CategoriesSection.allCases, id: \.header) { folder in
          Button(action: {
            category.section = folder
            showSelector.toggle()
          }, label: {
            EXSelectCell(title: folder.rawValue.capitalized, selectIcon: Source.Images.Navigation.checkmark, condition: category.section == folder)
          })
          .buttonStyle(EXPlainButtonStyle())
        }
      }.applyMargins()
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
      GridItem(.adaptive(minimum: 150)),
      GridItem(.adaptive(minimum: 150)),
      GridItem(.adaptive(minimum: 150)),
      GridItem(.adaptive(minimum: 150)),
    ]
  }
}

// MARK: - Realm Functions
extension AddCategoryView {
  func saveCategory() {
    AnalyticsManager.shared.log(.createCategory(category.name, category.section.header))
    category.tag = .custom
    try? realm.write {
      realm.add(category)
    }
  }
}
