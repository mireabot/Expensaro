//
//  RootTabBar.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/18/26.
//

import SwiftUI

/// The root tabs as one floating capsule, drawn by `RootTabView` over its pages.
/// Picking a tab writes `selection`; picking the selected tab again calls `reselect` instead.
struct RootTabBar: View {
  let tabs: [RouterTab]
  @Binding var selection: RouterTab
  let reselect: () -> Void

  @Namespace private var highlight

  var body: some View {
    HStack(spacing: 0) {
      ForEach(tabs) { tab in
        item(tab)
      }
    }
    .padding(Appearance.shared.inset)
    .frame(height: Appearance.shared.height)
    .floatingSurface(in: .capsule)
    .animation(.snappy(duration: 0.3), value: selection)
    .sensoryFeedback(.selection, trigger: selection)
  }
}

// MARK: - Appearance
extension RootTabBar {
  struct Appearance {
    static let shared = Appearance()

    /// Also the accessory button's size, so the two sit on one line
    let height: CGFloat = 62
    let inset: CGFloat = 4
    let iconSize: CGFloat = 24
  }
}

// MARK: - Helper Views
private extension RootTabBar {
  func item(_ tab: RouterTab) -> some View {
    let isSelected = tab == selection

    return Button {
      select(tab)
    } label: {
      VStack(spacing: 2) {
        Image(tab.icon)
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: Appearance.shared.iconSize, height: Appearance.shared.iconSize)
        Text(tab.label)
          .font(.system(size: 10, weight: .semibold))
          .lineLimit(1)
      }
      .foregroundStyle(isSelected ? Color.primaryGreen : Color.darkGrey)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background {
        if isSelected {
          Capsule()
            .fill(Color.primaryGreen.opacity(0.12))
            .matchedGeometryEffect(id: "selection", in: highlight)
        }
      }
      .contentShape(.capsule)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(tab.label)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

// MARK: - Helper Functions
private extension RootTabBar {
  func select(_ tab: RouterTab) {
    if tab == selection {
      reselect()
    } else {
      selection = tab
    }
  }
}

// MARK: - Floating surface
extension View {
  /// Background for controls floating over content: interactive Liquid Glass on iOS 26, material with a
  /// shadow below it. `clipsGlassShadow` drops the shadow glass draws outside `shape`, for a surface that
  /// changes shape and would otherwise carry it along mid-morph.
  @ViewBuilder
  func floatingSurface(tint: Color? = nil, in shape: some Shape, clipsGlassShadow: Bool = false) -> some View {
    if #available(iOS 26.0, *), clipsGlassShadow {
      glassEffect(.regular.tint(tint).interactive(), in: shape)
        .clipShape(shape)
    } else if #available(iOS 26.0, *) {
      glassEffect(.regular.tint(tint).interactive(), in: shape)
    } else {
      background {
        shape
          .fill(.ultraThinMaterial)
          .overlay { shape.fill(tint ?? .clear) }
          .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
      }
    }
  }
}
