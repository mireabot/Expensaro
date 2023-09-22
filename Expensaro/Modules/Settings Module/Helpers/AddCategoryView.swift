//
//  AddCategory.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/21/23.
//

import SwiftUI
import ExpensaroUIKit

struct AddCategoryView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  @FocusState var isFocused: Bool
  @State var text = ""
  @State private var categoryIcon: String = "archivebox.fill"
  @State private var changeIcon = false
  @State var detentHeight: CGFloat = 0
  let items: [GridItem] = [
    GridItem(.fixed(40), spacing: 20),
    GridItem(.fixed(40), spacing: 20),
  ]
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(alignment: .center, spacing: 15) {
            Image(systemName: categoryIcon)
              .font(.largeTitle)
              .foregroundColor(.primaryGreen)
              .frame(height: 45)
            
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
            EXTextField(text: $text, placeholder: "Required")
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
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            
          } label: {
            Appearance.shared.submitIcon
              .font(.callout)
              .foregroundColor(text.isEmpty ? .border : .black)
          }
          .disabled(text.isEmpty)
        }
      }
    }
  }
}

struct AddCategory_Previews: PreviewProvider {
  static var previews: some View {
    AddCategoryView()
  }
}

// MARK: - Appearance
extension AddCategoryView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "New category"
    
    let backIcon = Source.Images.Navigation.back
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
        ForEach(DefaultCategory.defaultSet){ item in
          Image(systemName: item.icon)
            .font(.title2)
            .frame(height: 40)
            .foregroundColor(.primaryGreen)
            .onTapGesture {
              categoryIcon = item.icon
              changeIcon.toggle()
            }
        }
      }
      .padding(.vertical, 15)
    }
  }
}
