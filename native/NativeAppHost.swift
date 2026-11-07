// The single seam between React Native and the native app.
//
// This is the only Swift file that knows about Expo. It registers one native
// view that React Native renders full-screen, and that view does nothing but
// host the pure-SwiftUI app (`TodoRootView`) in a UIHostingController.
// Everything under `TodoApp/` is plain SwiftUI with no RN/Expo imports.

internal import ExpoModulesCore
import SwiftUI
import UIKit

class NativeAppHost: Module {
  public func definition() -> ModuleDefinition {
    View(NativeAppHostView.self) {}
  }
}

final class NativeAppHostView: ExpoView {
  private let hostingController = UIHostingController(rootView: TodoRootView(hostLabel: "RN"))

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    hostingController.view.backgroundColor = .clear
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  // Attach the hosting controller to the real view-controller hierarchy so
  // SwiftUI gets proper safe areas, keyboard avoidance, sheets and navigation.
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil, hostingController.parent == nil, let parent = enclosingViewController() {
      parent.addChild(hostingController)
      hostingController.didMove(toParent: parent)
    } else if window == nil, hostingController.parent != nil {
      hostingController.willMove(toParent: nil)
      hostingController.removeFromParent()
    }
  }

  private func enclosingViewController() -> UIViewController? {
    var responder: UIResponder? = next
    while let current = responder {
      if let vc = current as? UIViewController { return vc }
      responder = current.next
    }
    return nil
  }
}
