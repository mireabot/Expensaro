//
//  FeatureRequestList.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 2/6/24.
//

import SwiftUI
import ExpensaroUIKit

struct FeatureRequestList: View {
  // MARK: Essential
  @EnvironmentObject var router: EXNavigationViewsRouter
  
  // MARK: Variables
  @State private var featureType = "Approved"
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing, content: {
        ScrollView(showsIndicators: false, content: {
          LazyVStack(alignment: .center, spacing: 10, pinnedViews: [.sectionHeaders], content: {
            Section {
              ForEach(1...15, id: \.self) { count in
                requestCell().applyMargins()
              }
            } header: {
              VStack {
                EXSegmentControl(currentTab: $featureType, type: .featureType)
                  .padding(.vertical, 10)
                  .applyMargins()
              }
              .background(.white)
            }
          })
        })
        .applyBounce()
        
        bottomActionButton().padding(16)
      })
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Appearance.shared.title)
            .font(.system(.headline, weight: .medium))
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
      }
    }
  }
}

#Preview {
  FeatureRequestList()
}

// MARK: - Appearance
extension FeatureRequestList {
  struct Appearance {
    static let shared = Appearance()
    
    let title = "Feature Requests"
    
    let backIcon = Source.Images.Navigation.back
  }
}

extension FeatureRequestList {
  @ViewBuilder
  func requestCell() -> some View {
    EXBaseCard {
      VStack(alignment: .leading, spacing: 3, content: {
        Text("Add app customization")
          .font(.title3Semibold)
        Text("I would like to see more flexibility like currency sign")
          .font(.footnoteRegular)
          .foregroundColor(.darkGrey)
          .lineLimit(0)
      })
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  
  @ViewBuilder
  func bottomActionButton() -> some View {
    Button(action: {}, label: {
      ZStack {
        Circle()
          .fill(Color.secondaryYellow)
          .frame(width: 60, height: 60)
        Source.Images.ButtonIcons.add
          .foregroundColor(.primaryGreen)
      }
    })
  }
}
