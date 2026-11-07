import Foundation
import SwiftData

/// Owns the SwiftData containers the app can run against.
@MainActor
enum TodoStore {
  /// The real, on-disk store. Seeded with sample to-dos on first launch.
  static let shared: ModelContainer = {
    let container: ModelContainer
    do {
      container = try ModelContainer(for: TodoItem.self)
    } catch {
      fatalError("Could not create the to-do store: \(error)")
    }
    seedOnFirstLaunch(container)
    return container
  }()

  private static let didSeedKey = "didSeedSamples"

  private static func seedOnFirstLaunch(_ container: ModelContainer) {
    let defaults = UserDefaults.standard
    guard !defaults.bool(forKey: didSeedKey) else { return }
    defaults.set(true, forKey: didSeedKey)

    let context = container.mainContext
    let existing = (try? context.fetchCount(FetchDescriptor<TodoItem>())) ?? 0
    guard existing == 0 else { return }
    TodoItem.makeSamples().forEach(context.insert)
    try? context.save()
  }
}

extension TodoStore {
  /// A throwaway in-memory store for Xcode Previews. Pass `[]` for the empty state.
  static func preview(_ items: [TodoItem] = TodoItem.makeSamples()) -> ModelContainer {
    do {
      let container = try ModelContainer(
        for: TodoItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
      items.forEach(container.mainContext.insert)
      return container
    } catch {
      fatalError("Could not create the preview store: \(error)")
    }
  }
}
