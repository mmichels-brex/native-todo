import SwiftData
import SwiftUI

/// Root of the native app. Owns navigation and which store it runs against;
/// knows nothing about the host that embeds it.
struct TodoRootView: View {
  /// Which shell is hosting the app (e.g. "RN", "Native"). Shown next to the
  /// title so side-by-side builds are easy to tell apart.
  var hostLabel: String? = nil

  /// The real on-disk store by default; previews pass an in-memory one.
  var container: ModelContainer = TodoStore.shared

  var body: some View {
    NavigationStack {
      TodoListView(hostLabel: hostLabel)
    }
    .modelContainer(container)
  }
}

#Preview("Sample to-dos") {
  TodoRootView(hostLabel: "Preview", container: TodoStore.preview())
}

#Preview("Empty") {
  TodoRootView(hostLabel: "Preview", container: TodoStore.preview([]))
}

#Preview("All done") {
  TodoRootView(
    hostLabel: "Preview",
    container: TodoStore.preview([
      TodoItem(title: "Write the PoC", isDone: true),
      TodoItem(title: "Push it to GitHub", isDone: true),
    ]))
}
