import SwiftData
import SwiftUI

/// Root of the native app. Owns persistence and navigation; knows nothing about
/// the host that embeds it.
struct TodoRootView: View {
  /// Which shell is hosting the app (e.g. "RN", "Native"). Shown next to the
  /// title so side-by-side builds are easy to tell apart.
  var hostLabel: String? = nil

  // Static so the store is opened once, no matter how often SwiftUI re-creates
  // this view value.
  private static let container: ModelContainer = {
    do {
      return try ModelContainer(for: TodoItem.self)
    } catch {
      fatalError("Could not create the to-do store: \(error)")
    }
  }()

  var body: some View {
    NavigationStack {
      TodoListView(hostLabel: hostLabel)
    }
    .modelContainer(Self.container)
  }
}
