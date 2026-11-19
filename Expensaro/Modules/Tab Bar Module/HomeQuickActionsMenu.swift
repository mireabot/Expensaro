//
//  HomeQuickActionsMenu.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/26.
//

import SwiftUI
import SwiftData
import ExpensaroUIKit

/// Home's add menu on iOS 26.
/// The tab bar's side button opens it, and the panel morphs out of that button as one glass
/// surface and back into it after a choice.
/// Adapted from SwiftUX "Morphing Floating Action Menu"
@available(iOS 26.0, *)
struct HomeQuickActionsMenu: View {
  @ObservedObject var coordinator: HomeQuickActionsCoordinator

  @Query(DailyTransaction.byDateCreated) private var dailyTransactions: [DailyTransaction]
  @AppStorage("currencySign") private var currencySign = "USD"
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // One haptic per tap: picking a row also closes the menu, so the close must not add its own
  @State private var feedback: SensoryFeedback = .impact(weight: .light)
  @State private var feedbackTick = 0
  @State private var didSelect = false

  private var motion: MorphingActionMenuMotion {
    MorphingActionMenuMotion(reduceMotion: reduceMotion)
  }

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      scrim

      MorphingActionMenuSurface(
        alignment: .bottomTrailing,
        progress: coordinator.isMenuExpanded ? 1 : 0,
        labelSize: Appearance.shared.buttonSize,
        cornerRadius: Appearance.shared.buttonSize.height / 2,
        expandedCornerRadius: 28,
        distortion: .trailingToLeading,
        distortionScale: motion.distortionScale
      ) {
        panel()
      } label: {
        trigger()
      }
      // Collapsed, the system side button is the control; the surface only takes taps while open
      .allowsHitTesting(coordinator.isMenuExpanded)
      .padding(.trailing, Appearance.shared.buttonInsets.trailing)
      .padding(.bottom, Appearance.shared.buttonInsets.bottom)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    .ignoresSafeArea(edges: .bottom)
    .animation(motion.morph, value: coordinator.isMenuExpanded)
    .sensoryFeedback(feedback, trigger: feedbackTick)
    .onChange(of: coordinator.isMenuExpanded) {
      if didSelect {
        didSelect = false
      } else {
        play(.impact(weight: .light))
      }
    }
  }
}

// MARK: - Apperance
@available(iOS 26.0, *)
extension HomeQuickActionsMenu {
  struct Appearance {
    static let shared = Appearance()

    /// Matches the system side button so the morph starts and ends on top of it
    let buttonSize = CGSize(width: 58, height: 58)
    let buttonInsets = (trailing: CGFloat(20), bottom: CGFloat(22))
    let panelWidth: CGFloat = 290
    /// The morph can't scroll, so only the first few daily transactions get a quick row
    let maxDailyRows = 4
  }
}

// MARK: - Helper Views
@available(iOS 26.0, *)
extension HomeQuickActionsMenu {
  /// Tap-anywhere dismissal. The puck is gone a third of the way into the morph,
  /// so without this the panel could only be closed by picking something
  @ViewBuilder
  var scrim: some View {
    if coordinator.isMenuExpanded {
      Color.black.opacity(0.001)
        .ignoresSafeArea()
        .contentShape(.rect)
        .onTapGesture {
          coordinator.isMenuExpanded = false
        }
    }
  }

  func trigger() -> some View {
    Image(systemName: "plus")
      .font(.system(size: 22, weight: .medium))
      .foregroundStyle(.primary)
      .rotationEffect(.degrees(coordinator.isMenuExpanded ? 45 : 0))
      .frame(width: Appearance.shared.buttonSize.width, height: Appearance.shared.buttonSize.height)
  }

  func panel() -> some View {
    VStack(alignment: .leading, spacing: 2) {
      if !dailyTransactions.isEmpty {
        Text("Daily transactions")
          .font(.system(.footnote, weight: .regular))
          .foregroundStyle(.secondary)
          .padding(.bottom, 4)
        ForEach(dailyTransactions.prefix(Appearance.shared.maxDailyRows)) { dailyTransaction in
          actionRow(title: dailyTransaction.name,
                    detail: dailyTransaction.amount.formattedAsCurrency(with: currencySign)) {
            Text(dailyTransaction.categoryIcon)
              .font(.system(size: 17))
          } action: {
            select(.addDailyTransaction(dailyTransaction))
          }
        }
      }
      actionRow(title: "Manage daily transactions") {
        Image(systemName: "plus")
          .font(.system(size: 15, weight: .semibold))
      } action: {
        select(.manageDailyTransactions)
      }

      Divider()
        .padding(.vertical, 6)

      actionRow(title: "Add transaction") {
        assetIcon("buttonTransaction")
      } action: {
        select(.addTransaction)
      }
      actionRow(title: "Add recurring payment") {
        assetIcon("buttonRecurrent")
      } action: {
        select(.addRecurringPayment)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    // Fixed width: the surface measures the panel under `fixedSize`, so long names would
    // otherwise widen it past the screen instead of truncating
    .frame(width: Appearance.shared.panelWidth)
  }

  func actionRow<Icon: View>(title: String,
                             detail: String? = nil,
                             @ViewBuilder icon: () -> Icon,
                             action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        icon()
          .foregroundStyle(Color.primaryGreen)
          .frame(width: 38, height: 38)
          .background(Color.primaryGreen.opacity(0.1), in: .circle)
        Text(title)
          .font(.system(.subheadline, weight: .medium))
          .foregroundStyle(.primary)
          .lineLimit(1)
        Spacer(minLength: 8)
        if let detail {
          Text(detail)
            .font(.system(.footnote, weight: .regular))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
      }
      .frame(height: 46)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
  }

  func assetIcon(_ name: String) -> some View {
    Image(name)
      .renderingMode(.template)
      .resizable()
      .scaledToFit()
      .frame(width: 18, height: 18)
  }
}

// MARK: - Helper Functions
@available(iOS 26.0, *)
extension HomeQuickActionsMenu {
  func select(_ action: HomeQuickAction) {
    didSelect = true
    play(.selection)
    coordinator.perform(action)
  }

  func play(_ next: SensoryFeedback) {
    feedback = next
    feedbackTick += 1
  }
}

// MARK: - Morph surface
/// Squash-and-stretch applied mid-flight. Every value peaks halfway and is zero at both ends,
/// so the surface is undistorted at rest in either state
struct MorphDistortion {
  var scaleX: CGFloat
  var scaleY: CGFloat
  var offset: CGSize
  var blurRadius: CGFloat
  /// Fraction of the morph spent handing the puck over to the panel; they never crossfade
  var handoff: CGFloat = 0.35

  /// Stretches toward the leading edge, the direction the panel travels from a trailing puck
  static let trailingToLeading = MorphDistortion(
    scaleX: 0.14,
    scaleY: -0.10,
    offset: CGSize(width: -12, height: -6),
    blurRadius: 10
  )
}

/// Open and close are the same curve played backwards. Reduced motion keeps the morph
/// (it explains where the panel came from) and drops the bounce and distortion
struct MorphingActionMenuMotion {
  var reduceMotion: Bool = false

  var morph: Animation {
    reduceMotion
      ? .easeOut(duration: 0.25)
      : .bouncy(duration: 0.5, extraBounce: 0.05)
  }

  var distortionScale: CGFloat {
    reduceMotion ? 0 : 1
  }
}

/// One glass surface whose frame is interpolated between the puck and the panel.
/// The glass is applied once over the interpolated shape, so it reads as one object
/// rather than two views crossfading. `Animatable` on `progress` makes every curve below
/// evaluate per frame instead of snapping between two layouts
@available(iOS 26.0, *)
struct MorphingActionMenuSurface<Content: View, Label: View>: View, Animatable {
  var alignment: Alignment
  /// 0 collapsed, 1 expanded
  var progress: CGFloat
  /// Can't be measured: at rest the panel isn't laid out
  var labelSize: CGSize
  var cornerRadius: CGFloat
  var expandedCornerRadius: CGFloat
  var distortion: MorphDistortion
  var distortionScale: CGFloat = 1

  @ViewBuilder var content: Content
  @ViewBuilder var label: Label

  @State private var contentSize: CGSize = .zero

  var animatableData: CGFloat {
    get { progress }
    set { progress = newValue }
  }

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: currentCornerRadius, style: .continuous)

    ZStack(alignment: alignment) {
      panel
      puck
    }
    .compositingGroup()
    .clipShape(shape)
    .glassEffect(.regular.interactive(), in: shape)
    // Clipped again after the glass to drop the shadow `glassEffect` draws outside the shape
    .clipShape(shape)
    .scaleEffect(
      x: 1 + (distortion.scaleX * flight * distortionScale),
      y: 1 + (distortion.scaleY * flight * distortionScale),
      anchor: scaleAnchor
    )
    .offset(
      x: distortion.offset.width * flight * distortionScale,
      y: distortion.offset.height * flight * distortionScale
    )
    // At rest the system side button underneath is the visible control
    .opacity(min(progress / 0.08, 1))
  }

  private var panel: some View {
    content
      .compositingGroup()
      .scaleEffect(contentScale, anchor: scaleAnchor)
      .blur(radius: distortion.blurRadius * flight * distortionScale)
      .opacity(contentOpacity)
      .allowsHitTesting(contentOpacity > 0)
      // Order is load-bearing: this reads the size above it, where `fixedSize` below
      // proposes nil, so it sees the panel's natural size and never the interpolated frame
      .onGeometryChange(for: CGSize.self) { $0.size } action: { contentSize = $0 }
      .fixedSize()
      .frame(
        width: labelSize.width + growth.width,
        height: labelSize.height + growth.height,
        alignment: alignment
      )
  }

  private var puck: some View {
    label
      .compositingGroup()
      .blur(radius: distortion.blurRadius * flight * distortionScale)
      .opacity(1 - labelOpacity)
      .allowsHitTesting(labelOpacity < 1)
      .frame(width: labelSize.width, height: labelSize.height)
  }

  // MARK: Curves
  /// Puck fade, complete by `handoff`
  private var labelOpacity: CGFloat {
    min(progress / distortion.handoff, 1)
  }

  /// Panel arrival, starts at `handoff`
  private var contentOpacity: CGFloat {
    max(progress - distortion.handoff, 0) / (1 - distortion.handoff)
  }

  /// Grows on the panel's curve so the puck doesn't stretch while the glyph is still in it
  private var growth: CGSize {
    CGSize(
      width: max(contentSize.width - labelSize.width, 0) * contentOpacity,
      height: max(contentSize.height - labelSize.height, 0) * contentOpacity
    )
  }

  /// Starts at the scale that fits the panel inside the puck
  private var contentScale: CGFloat {
    guard contentSize.width > 0, contentSize.height > 0 else { return 1 }
    let fitted = min(labelSize.width / contentSize.width, labelSize.height / contentSize.height)
    return fitted + (1 - fitted) * progress
  }

  private var currentCornerRadius: CGFloat {
    cornerRadius + (expandedCornerRadius - cornerRadius) * contentOpacity
  }

  /// Triangle: 0 at both ends, 1 halfway. Everything decorative hangs off this
  private var flight: CGFloat {
    progress > 0.5 ? (1 - progress) / 0.5 : progress / 0.5
  }

  private var scaleAnchor: UnitPoint {
    switch alignment {
    case .bottomLeading: .bottomLeading
    case .bottom: .bottom
    case .bottomTrailing: .bottomTrailing
    case .topLeading: .topLeading
    case .top: .top
    case .topTrailing: .topTrailing
    case .leading: .leading
    case .trailing: .trailing
    default: .center
    }
  }
}
