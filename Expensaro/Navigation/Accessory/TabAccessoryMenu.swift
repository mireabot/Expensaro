//
//  TabAccessoryMenu.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/2/26.
//

import SwiftUI
import ExpensaroUIKit

/// The button beside the root tab bar. Tapping it morphs a panel out of it as one surface, and the panel
/// morphs back after a choice. Rows come from `AccessoryContent`; with none the button fades out in place,
/// keeping its slot so the bar never relayouts. Glass on iOS 26, material below.
/// Adapted from SwiftUX "Morphing Floating Action Menu"
struct TabAccessoryMenu: View {
  let content: AccessoryContent
  @Binding var isExpanded: Bool

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // One haptic per tap: picking a row also closes the menu, so the close must not add its own
  @State private var feedback: SensoryFeedback = .impact(weight: .light)
  @State private var feedbackTick = 0
  @State private var didSelect = false

  private var motion: MorphingActionMenuMotion {
    MorphingActionMenuMotion(reduceMotion: reduceMotion)
  }

  var body: some View {
    // The slot is sized by the button alone; the surface grows in an overlay, outside the layout
    Color.clear
      .frame(width: Appearance.shared.buttonSize.width, height: Appearance.shared.buttonSize.height)
      .overlay(alignment: .bottomTrailing) {
        MorphingActionMenuSurface(
          alignment: .bottomTrailing,
          progress: isExpanded ? 1 : 0,
          labelSize: Appearance.shared.buttonSize,
          cornerRadius: Appearance.shared.buttonSize.height / 2,
          expandedCornerRadius: 28,
          distortion: .trailingToLeading,
          distortionScale: motion.distortionScale,
          glassTint: isItem ? .primaryGreen : nil
        ) {
          panel()
        } label: {
          trigger()
        }
      }
      .opacity(content.isEmpty ? 0 : 1)
      .scaleEffect(content.isEmpty ? 0.6 : 1)
      .allowsHitTesting(!content.isEmpty)
      .accessibilityHidden(content.isEmpty)
      .animation(motion.morph, value: isExpanded)
      .animation(.smooth(duration: 0.3), value: isItem)
      .animation(.smooth(duration: 0.25), value: content.isEmpty)
      .sensoryFeedback(feedback, trigger: feedbackTick)
      .onChange(of: isExpanded) {
        if didSelect {
          didSelect = false
        } else {
          play(.impact(weight: .light))
        }
      }
  }
}

// MARK: - Apperance
extension TabAccessoryMenu {
  struct Appearance {
    static let shared = Appearance()

    let buttonSize = CGSize(width: RootTabBar.Appearance.shared.height, height: RootTabBar.Appearance.shared.height)
    let panelWidth: CGFloat = 290
  }
}

// MARK: - Helper Views
extension TabAccessoryMenu {
  func trigger() -> some View {
    Button {
      isExpanded.toggle()
    } label: {
      Image(systemName: isItem ? "ellipsis" : "plus")
        .font(.system(size: 22, weight: .medium))
        .foregroundStyle(isItem ? AnyShapeStyle(Color.white) : AnyShapeStyle(.primary))
        .contentTransition(.symbolEffect(.replace))
        .rotationEffect(.degrees(isExpanded && !isItem ? 45 : 0))
        .frame(width: Appearance.shared.buttonSize.width, height: Appearance.shared.buttonSize.height)
        .contentShape(.circle)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(isItem ? "More actions" : "Add")
  }

  func panel() -> some View {
    VStack(alignment: .leading, spacing: 2) {
      ForEach(content.sections) { section in
        VStack(alignment: .leading, spacing: 2) {
          if section.id != content.sections.first?.id {
            Divider()
              .padding(.vertical, 6)
          }
          if let title = section.title {
            Text(title)
              .font(.system(.footnote, weight: .regular))
              .foregroundStyle(.secondary)
              .padding(.bottom, 4)
          }
          ForEach(section.actions, id: \.rowID) { action in
            actionRow(action)
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    // Fixed width: the surface measures the panel under `fixedSize`, so long names would
    // otherwise widen it past the screen instead of truncating
    .frame(width: Appearance.shared.panelWidth)
  }

  func actionRow(_ action: AccessoryAction) -> some View {
    let accent = action.role == .destructive ? Color.red : Color.primaryGreen

    return Button {
      select(action)
    } label: {
      HStack(spacing: 12) {
        icon(action.icon)
          .foregroundStyle(accent)
          .frame(width: 38, height: 38)
          .background(accent.opacity(0.1), in: .circle)
        Text(action.title)
          .font(.system(.subheadline, weight: .medium))
          .foregroundStyle(action.role == .destructive ? AnyShapeStyle(Color.red) : AnyShapeStyle(.primary))
          .lineLimit(1)
        Spacer(minLength: 8)
        if let detail = action.detail {
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

  @ViewBuilder
  func icon(_ icon: AccessoryAction.Icon) -> some View {
    switch icon {
    case let .asset(name):
      Image(name)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)
    case let .symbol(name):
      Image(systemName: name)
        .font(.system(size: 15, weight: .semibold))
    case let .emoji(emoji):
      Text(emoji)
        .font(.system(size: 17))
    }
  }
}

// MARK: - Helper Functions
extension TabAccessoryMenu {
  var isItem: Bool {
    content.style == .item
  }

  func select(_ action: AccessoryAction) {
    didSelect = true
    play(.selection)
    isExpanded = false
    action.perform()
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
/// evaluate per frame instead of snapping between two layouts. Glass on iOS 26, material below
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
  /// Fades out as the panel arrives, so the open panel reads as plain glass
  var glassTint: Color? = nil

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
    .floatingSurface(tint: glassTint?.opacity(1 - contentOpacity), in: shape, clipsGlassShadow: true)
    .scaleEffect(
      x: 1 + (distortion.scaleX * flight * distortionScale),
      y: 1 + (distortion.scaleY * flight * distortionScale),
      anchor: scaleAnchor
    )
    .offset(
      x: distortion.offset.width * flight * distortionScale,
      y: distortion.offset.height * flight * distortionScale
    )
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
