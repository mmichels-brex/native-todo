import SwiftUI

/// Pure-native entrypoint: runs the exact same app that React Native hosts in
/// the Expo build, with no RN, Expo or CocoaPods involved.
@main
struct TodoStandaloneApp: App {
  var body: some Scene {
    WindowGroup {
      TodoRootView(hostLabel: "Native")
    }
  }
}
