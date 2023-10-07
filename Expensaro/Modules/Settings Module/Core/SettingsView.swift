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
  let items: [GridItem] = [
    GridItem(.fixed(50), spacing: 20),
    GridItem(.fixed(50), spacing: 20),
  ]
  
  @State var offset: CGFloat = 0
  @State var profileName = UserDefaults.standard.string(forKey: "profileName") ?? ""
  @State private var selectedCategory = ""
  @FocusState private var nameField: Bool
  @State var detentHeight: CGFloat = 0
  @State private var profileEmoji: String = (UserDefaults.standard.string(forKey: "profileEmoji") ?? "👤")
  
  @State private var showEmojiSelector = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 15) {
          GeometryReader { proxy in
            
            topBar(topEndge: proxy.safeAreaInsets.top, offset: $offset, text: $profileName)
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
      .sheet(isPresented: $showEmojiSelector, content: {
        emojiGrid()
          .readHeight()
          .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
              self.detentHeight = height
            }
          }
          .presentationDetents([.height(self.detentHeight)])
      })
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
            UserDefaults.standard.set(profileName, forKey: "profileName")
            UserDefaults.standard.synchronize()
            nameField = false
          } label: {
            Source.Images.Navigation.checkmark
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
    
    let emojis = ["👷", "💂‍♀️","🕵️", "🧑‍⚕️", "👨‍⚕️", "👩‍🌾", "👨‍🌾", "👩‍🍳", "👨‍🍳", "👩‍🎓", "👨‍🎓", "🧑‍🎤", "👨‍🎤", "👩‍🏫", "👨‍🏫", "👩‍🏭", "👨‍🏭", "👩‍💻", "👨‍💻", "🫅", "🤴", "👰‍♀️"]
  }
}

// MARK: - Helper Views
extension SettingsView {
  @ViewBuilder
  func topBar(topEndge: CGFloat, offset: Binding<CGFloat>, text: Binding<String>) -> some View {
    VStack(spacing: 10) {
      Button {
        showEmojiSelector.toggle()
      } label: {
        Text(profileEmoji)
          .font(.largeTitle)
          .padding(20)
          .background(Color.backgroundGrey)
          .cornerRadius(60)
      }
      TextField("Your name", text: $profileName)
        .keyboardType(.alphabet)
        .autocorrectionDisabled()
        .multilineTextAlignment(.center)
        .focused($nameField)
        .font(.mukta(.semibold, size: 20))
        .foregroundColor(.black)
        .tint(.primaryGreen)
    }.padding(.bottom, 20)
  }
  
  @ViewBuilder
  func emojiGrid() -> some View {
    VStack(spacing: 0) {
      Button {
        UserDefaults.standard.set(profileEmoji, forKey: "profileEmoji")
        UserDefaults.standard.synchronize()
        showEmojiSelector.toggle()
      } label: {
        Source.Images.Navigation.checkmark
          .font(.callout)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .applyMargins()
          .padding(.vertical, 10)
      }
      
      Divider()
      
      ScrollView(.horizontal, showsIndicators: false, content: {
        LazyHGrid(rows: items, spacing: 20) {
          ForEach(Appearance.shared.emojis, id: \.self) { emoji in
            Text(emoji)
              .font(.largeTitle)
              .onTapGesture {
                profileEmoji = emoji
                UserDefaults.standard.set(profileEmoji, forKey: "profileEmoji")
                UserDefaults.standard.synchronize()
                showEmojiSelector.toggle()
              }
          }
        }
        .applyMargins()
      })
      .padding(.top, 20)
    }
  }
}

extension SettingsView {
  private func navigateTo() {
    switch selectedCategory {
    case "Categories": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(CategoriesSettingsView()))
    case "Reminders": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(RemindersSettingsView()))
    case "Export Data": print("Navigation error")
    case "Reset Data": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(EraseDataSettingsView()))
    case "Contact": router.pushTo(view: EXNavigationViewBuilder.builder.makeView(ContactSettingsView()))
    default: print("Navigation error")
    }
  }
}
