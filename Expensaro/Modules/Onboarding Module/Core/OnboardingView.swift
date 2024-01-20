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
  let appIcon = Bundle.main.icon
  init() {
    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primaryGreen)
    UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.border)
  }
  var body: some View {
    NavigationView {
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: {
        ToolbarItem(placement: .topBarLeading) {
          Image(uiImage: appIcon!)
            .resizable()
            .frame(width: 50, height: 50)
            .aspectRatio(contentMode: .fit)
        }
      })
    }
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
        Text("Categorize your expenses with personalized labels and monitor your spendings in one app")
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
        Text("Keep up with recurring payments")
          .font(.system(.title2, weight: .semibold))
        Text("Monitor due dates and receive reminders for impending payments. Manage your recurring bills and never miss a deadline")
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
        Text("Accelerate your financial goals")
          .font(.system(.title2, weight: .semibold))
        Text("Define your financial targets and gain access to machine learning-driven insights for quicker achievement")
          .font(.system(.headline, weight: .regular))
          .foregroundColor(.darkGrey)
          .kerning(0.204)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, 30)
    }
  }
}
