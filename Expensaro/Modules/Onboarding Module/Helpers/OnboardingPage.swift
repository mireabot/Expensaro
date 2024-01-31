//
//  OnboardingPage.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 1/29/24.
//

import SwiftUI

struct OnboardingPage: View {
  @State private var animateHint = false
  var feature: AppFeatures
  
  init(feature: AppFeatures) {
    self.feature = feature
  }
  
  var body: some View {
    VStack {
      VStack(alignment: .center, spacing: 10, content: {
        feature.icon
        
        VStack(alignment: .center, spacing: 3, content: {
          Text(feature.title)
            .font(.titleBold)
            .multilineTextAlignment(.center)
          Text(feature.text)
            .font(.headlineRegular)
            .foregroundColor(.darkGrey)
            .multilineTextAlignment(.center)
          
          if feature == .customCategories {
            VStack(spacing: 0) {
              Text("Swipe for more")
                .font(.footnoteMedium)
                .offset(y: animateHint ? 0 : 3)
              Source.Images.Navigation.swipeDirections
                .resizable()
                .frame(width: 20, height: 20)
                .offset(y: animateHint ? 0 : 6)
            }
            .foregroundColor(.primaryGreen)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateHint)
            .onAppear {
              animateHint = true
            }
          }
        })
        .frame(maxWidth: .infinity, alignment: .center)
        .applyMargins()
      })
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }
}
