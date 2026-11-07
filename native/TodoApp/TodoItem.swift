import Foundation
import SwiftData

@Model
final class TodoItem {
  var title: String
  var isDone: Bool
  var createdAt: Date
  var completedAt: Date?

  init(title: String, isDone: Bool = false, createdAt: Date = .now) {
    self.title = title
    self.isDone = isDone
    self.createdAt = createdAt
    self.completedAt = isDone ? createdAt : nil
  }

  func setDone(_ done: Bool) {
    isDone = done
    completedAt = done ? .now : nil
  }
}

extension TodoItem {
  static let activeSort = [SortDescriptor(\TodoItem.createdAt, order: .reverse)]
  static let completedSort = [SortDescriptor(\TodoItem.completedAt, order: .reverse)]

  static func makeSamples() -> [TodoItem] {
    [
      TodoItem(title: "Try swiping a row in either direction", createdAt: .now.addingTimeInterval(-30)),
      TodoItem(title: "Tap a title to edit it in place", createdAt: .now.addingTimeInterval(-20)),
      TodoItem(title: "Add a to-do from the field below", createdAt: .now.addingTimeInterval(-10)),
      TodoItem(title: "Open the app", isDone: true, createdAt: .now.addingTimeInterval(-60)),
    ]
  }
}
