//
//  EXNumberKeyboard.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 10/14/23.
//

import SwiftUI
import ExpensaroUIKit

/// Custom TextField Keyboard TextField Modifier
extension TextField {
  @ViewBuilder
  func inputView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
    self
      .background {
        SetTFKeyboard(keyboardContent: content())
      }
  }
}

extension View {
  @ViewBuilder
  func inputView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
    self
      .background {
        SetTFKeyboard(keyboardContent: content())
      }
  }
}

fileprivate struct SetTFKeyboard<Content: View>: UIViewRepresentable {
  var keyboardContent: Content
  @State private var hostingController: UIHostingController<Content>?
  
  func makeUIView(context: Context) -> UIView {
    return UIView()
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    DispatchQueue.main.async {
      if let textFieldContainerView = uiView.superview?.superview {
        if let textField = textFieldContainerView.findTextField {
          /// If the input is already set, then updating it's content
          if textField.inputView == nil {
            /// Now with the help of UIHosting Controller converting SwiftUI View into UIKit View
            hostingController = UIHostingController(rootView: keyboardContent)
            hostingController?.view.frame = .init(origin: .zero, size: hostingController?.view.intrinsicContentSize ?? .zero)
            /// Setting TF's Input view as our SwiftUI View
            textField.inputView = hostingController?.view
          } else {
            /// Updating Hosting Content
            hostingController?.rootView = keyboardContent
          }
        } else {
          print("Failed to Find TF")
        }
      }
    }
  }
}

/// Extracting TextField From the Subviews
fileprivate extension UIView {
  var allSubViews: [UIView] {
    return subviews.flatMap { [$0] + $0.subviews }
  }
  
  /// Finiding the UIView is TextField or Not
  var findTextField: UITextField? {
    if let textField = allSubViews.first(where: { view in
      view is UITextField
    }) as? UITextField {
      return textField
    }
    
    return nil
  }
}


struct KeyPadButton: View {
  var key: String
  
  var body: some View {
    Button(action: { self.action(self.key) }) {
      if key == "Done" {
        Text(key)
          .font(.system(.title3, weight: .semibold))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(10)
          .background(Color.primaryGreen)
          .cornerRadius(12)
      } else {
        Text(key)
          .font(.system(.title3, weight: .semibold))
          .frame(maxWidth: .infinity)
          .padding(10)
          .background(Color.backgroundGrey)
          .cornerRadius(12)
      }
    }
    .buttonStyle(EXPlainButtonStyle())
  }
  
  enum ActionKey: EnvironmentKey {
    static var defaultValue: (String) -> Void { { _ in } }
  }
  
  @Environment(\.keyPadButtonAction) var action: (String) -> Void
}

extension EnvironmentValues {
  var keyPadButtonAction: (String) -> Void {
    get { self[KeyPadButton.ActionKey.self] }
    set { self[KeyPadButton.ActionKey.self] = newValue }
  }
}

#if DEBUG
struct KeyPadButton_Previews: PreviewProvider {
  static var previews: some View {
    KeyPadButton(key: "Done")
      .padding()
      .frame(height: 80)
      .previewLayout(.sizeThatFits)
  }
}
#endif

struct KeyPadRow: View {
  var keys: [String]
  
  var body: some View {
    HStack {
      ForEach(keys, id: \.self) { key in
        KeyPadButton(key: key)
      }
    }
  }
}


struct EXNumberKeyboard: View {
  @Binding var textValue: String
  var submitAction: () -> Void
  var body: some View {
    VStack {
      KeyPadRow(keys: ["1", "2", "3"])
      KeyPadRow(keys: ["4", "5", "6"])
      KeyPadRow(keys: ["7", "8", "9"])
      KeyPadRow(keys: [".", "0", "Done"])
    }.environment(\.keyPadButtonAction, self.keyWasPressed(_:))
  }
  
  private func keyWasPressed(_ key: String) {
    switch key {
    case "." where textValue.contains("."): break
    case "." where textValue == "0": textValue += key
    case "Done": submitAction()
    case _ where textValue == "0.0": textValue = key
    default: textValue += key
    }
  }
}
