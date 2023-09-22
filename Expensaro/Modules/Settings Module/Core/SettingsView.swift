//
//  SettingsView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/18/23.
//

import SwiftUI
import ExpensaroUIKit

struct SettingsView: View {
  @EnvironmentObject var router: EXNavigationViewsRouter
  let maxHeight = UIScreen.main.bounds.height / 5
  @State var offset: CGFloat = 0
  @State var text = ""
  @State private var selectedCategory = ""
  @FocusState private var nameField: Bool
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 15) {
          GeometryReader { proxy in
            
            topBar(topEndge: proxy.safeAreaInsets.top, offset: $offset, text: $text)
            .frame(maxWidth: .infinity, alignment: .top)
            .frame(height: maxHeight + offset, alignment: .bottom)
            .background(.white)
            .shadowXS()
          }
          .frame(height: maxHeight)
          .offset(y: -offset)
          
          VStack {
            HStack {
              EXSettingsCell(category: $selectedCategory, type: .categories, action: {navigateTo()})
              EXSettingsCell(category: $selectedCategory, type: .reminders, action: {navigateTo()})
            }
            HStack {
              EXSettingsCell(category: $selectedCategory, type: .exportData, action: {navigateTo()})
              EXSettingsCell(category: $selectedCategory, type: .resetAccount, action: {navigateTo()})
            }
            HStack {
              EXSettingsCell(category: $selectedCategory, type: .contact, action: {navigateTo()})
            }
          }
          .disabled(nameField)
          .applyMargins()
        }
        .modifier(OffsetModifier(offset: $offset))
      }
      .coordinateSpace(name: "SCROLL")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.white, for: .bottomBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            router.nav?.popViewController(animated: true)
          } label: {
            Appearance.shared.backIcon
              .font(.callout)
              .foregroundColor(.black)
          }
        }
        
        ToolbarItem(placement: .keyboard) {
          Button {
            nameField = false
          } label: {
            Source.Images.Navigation.checkmark
              .font(.callout)
              .foregroundColor(.primaryGreen)
          }
          .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.mukta(.medium, size: 17))
        }
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

// MARK: - Appearance
extension SettingsView {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Settings"
    
    let backIcon = Source.Images.Navigation.back
  }
}

// MARK: - Helper Views
extension SettingsView {
  @ViewBuilder
  func topBar(topEndge: CGFloat, offset: Binding<CGFloat>, text: Binding<String>) -> some View {
    VStack(spacing: 10) {
      Button {
        
      } label: {
        Source.Images.System.scan
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.primaryGreen)
          .padding(20)
          .background(Color.border)
          .cornerRadius(60)
      }
      TextField("Your name", text: $text)
        .keyboardType(.alphabet)
        .autocorrectionDisabled()
        .multilineTextAlignment(.center)
        .focused($nameField)
        .font(.mukta(.semibold, size: 20))
        .foregroundColor(.black)
        .tint(.primaryGreen)
    }.padding(.bottom, 20)
  }
}

extension SettingsView {
  private func navigateTo() {
    switch selectedCategory {
    case "Categories": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(AddCategoryView()))
    case "Reminders": print("Navigation error")
    case "Export Data": print("Navigation error")
    case "Reset Data": print("Navigation error")
    case "Contact": print("Navigation error")
    default: print("Navigation error")
    }
  }
}
