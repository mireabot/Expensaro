//
//  OmboardingView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit

struct OnboardingView: View {
  @State private var showPermission = false
  var body: some View {
    NavigationView {
      VStack {
        VStack(alignment: .leading, spacing: 0, content: {
          Text("Expensaro")
            .font(.largeTitleBold)
            .foregroundColor(.black)
          Text("Your Finance Diary")
            .font(.headline)
            .foregroundColor(.darkGrey)
        })
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .applyMargins()
        GeometryReader { proxy in
          TabView {
            ForEach(AppFeatures.allCases, id: \.title) { feature in
              OnboardingPage(feature: feature)
            }
            .rotationEffect(.degrees(-90))
            .frame(
              width: proxy.size.width,
              height: proxy.size.height
            )
          }
          .frame(
            width: proxy.size.height,
            height: proxy.size.width
          )
          .rotationEffect(.degrees(90), anchor: .topLeading)
          .offset(x: proxy.size.width)
          .tabViewStyle(
            PageTabViewStyle(indexDisplayMode: .never)
          )
        }
        .safeAreaInset(edge: .bottom) {
          Button(action: {
            showPermission.toggle()
          }, label: {
            Text("Get Started")
              .font(.headlineSemibold)
          })
          .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
          .padding(.vertical, 10)
          .applyMargins()
        }
      }
      .sheet(isPresented: $showPermission, content: {
        InitialPermissionView()
          .presentationDragIndicator(.visible)
          .presentationDetents([.fraction(0.8)])
      })
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView()
  }
}
