//
//  OmboardingView.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 9/15/23.
//

import SwiftUI
import ExpensaroUIKit

struct OnboardingView: View {
  @State var currentPage: Int = 0
  @State private var showPermission = false
  init() {
    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primaryGreen)
    UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.border)
  }
  var body: some View {
    VStack {
      TabView {
        firstTab()
        secondTab()
        thirdTab()
      }
      .tabViewStyle(.page)
      
      Button {
        showPermission.toggle()
      } label: {
        Text("Get started")
          .font(.system(.headline, weight: .semibold))
      }
      .buttonStyle(EXPrimaryButtonStyle(showLoader: .constant(false)))
      .padding(.bottom, 20)
    }
    .sheet(isPresented: $showPermission, content: {
      InitialPermissionView()
        .presentationDragIndicator(.visible)
        .presentationDetents([.fraction(0.8)])
    })
    .applyMargins()
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView()
  }
}

extension OnboardingView {
  @ViewBuilder
  func firstTab() -> some View {
    VStack(alignment: .center, spacing: 0) {
      Source.Images.Onboarding.onb1
      VStack(alignment: .leading, spacing: 5) {
        Source.Images.Onboarding.transactions
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.primaryGreen)
        Text("Keep all transactions in one place")
          .font(.system(.title2, weight: .semibold))
        Text("Add your own expense categories, scan receipts for automatic transaction filling, and effortlessly keep track of your spending")
          .font(.system(.headline, weight: .regular))
          .foregroundColor(.darkGrey)
          .kerning(0.204)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 30)
    }
  }
  
  @ViewBuilder
  func secondTab() -> some View {
    VStack(alignment: .center, spacing: 0) {
      Source.Images.Onboarding.onb2
      VStack(alignment: .leading, spacing: 5) {
        Source.Images.Onboarding.recurrentPayments
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.primaryGreen)
        Text("Keep up with recurrent payments")
          .font(.system(.title2, weight: .semibold))
        Text("Easily track due dates and receive advance reminders for upcoming payments, stay on top of your recurring bills")
          .font(.system(.headline, weight: .regular))
          .foregroundColor(.darkGrey)
          .kerning(0.204)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 30)
    }
  }
  
  @ViewBuilder
  func thirdTab() -> some View {
    VStack(alignment: .center, spacing: 0) {
      Source.Images.Onboarding.onb3
      VStack(alignment: .leading, spacing: 5) {
        Source.Images.Onboarding.goals
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.primaryGreen)
        Text("Achieve financial goals faster")
          .font(.system(.title2, weight: .semibold))
        Text("Create your unique financial objectives and receive insights, powered by machine learning, how to make it faster")
          .font(.system(.headline, weight: .regular))
          .foregroundColor(.darkGrey)
          .kerning(0.204)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 30)
    }
  }
}
