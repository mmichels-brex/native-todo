import SwiftData
import SwiftUI

struct TodoListView: View {
  var hostLabel: String? = nil

  @Environment(\.modelContext) private var context

  @Query(filter: #Predicate<TodoItem> { !$0.isDone }, sort: TodoItem.activeSort, animation: .snappy)
  private var active: [TodoItem]

  @Query(filter: #Predicate<TodoItem> { $0.isDone }, sort: TodoItem.completedSort, animation: .snappy)
  private var completed: [TodoItem]

  @State private var showCompleted = true
  @State private var completionTick = 0

  private var total: Int { active.count + completed.count }

  var body: some View {
    List {
      if total > 0 {
        Section {
          ProgressSummary(done: completed.count, total: total)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
      }

      if !active.isEmpty {
        Section("To Do") {
          ForEach(active) { row(for: $0) }
        }
      }

      if !completed.isEmpty {
        Section("Completed", isExpanded: $showCompleted) {
          ForEach(completed) { row(for: $0) }
        }
      }
    }
    .listStyle(.insetGrouped)
    .overlay {
      if total == 0 {
        ContentUnavailableView(
          "Nothing to do",
          systemImage: "checklist",
          description: Text("Add your first to-do below.")
        )
        .transition(.opacity)
      }
    }
    .animation(.snappy, value: total == 0)
    .navigationTitle(hostLabel.map { "To-Dos · \($0)" } ?? "To-Dos")
    .toolbar { toolbarMenu }
    .safeAreaInset(edge: .bottom) {
      TodoComposer(onAdd: add)
    }
    .scrollDismissesKeyboard(.interactively)
    .sensoryFeedback(.success, trigger: completionTick)
  }

  private func row(for item: TodoItem) -> some View {
    TodoRow(item: item, onToggle: { toggle(item) }, onDelete: { delete(item) })
      .swipeActions(edge: .leading, allowsFullSwipe: true) {
        Button {
          toggle(item)
        } label: {
          Label(item.isDone ? "Undo" : "Done",
                systemImage: item.isDone ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(item.isDone ? .orange : .green)
      }
      .swipeActions(edge: .trailing, allowsFullSwipe: true) {
        Button(role: .destructive) {
          delete(item)
        } label: {
          Label("Delete", systemImage: "trash")
        }
      }
      .contextMenu {
        Button(item.isDone ? "Mark as Not Done" : "Mark as Done",
               systemImage: item.isDone ? "circle" : "checkmark.circle") { toggle(item) }
        Button("Delete", systemImage: "trash", role: .destructive) { delete(item) }
      }
  }

  @ToolbarContentBuilder
  private var toolbarMenu: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Menu {
        Button("Complete All", systemImage: "checkmark.circle") {
          withAnimation(.snappy) { active.forEach { $0.setDone(true) } }
          save()
          completionTick += 1
        }
        .disabled(active.isEmpty)

        Button("Clear Completed", systemImage: "trash", role: .destructive) {
          withAnimation(.snappy) { completed.forEach(context.delete) }
          save()
        }
        .disabled(completed.isEmpty)
      } label: {
        Label("More", systemImage: "ellipsis")
      }
    }
  }

  private func add(_ title: String) {
    withAnimation(.snappy) {
      context.insert(TodoItem(title: title))
    }
    save()
  }

  private func toggle(_ item: TodoItem) {
    withAnimation(.snappy) { item.setDone(!item.isDone) }
    save()
    if item.isDone { completionTick += 1 }
  }

  private func delete(_ item: TodoItem) {
    withAnimation(.snappy) { context.delete(item) }
    save()
  }

  /// SwiftData's autosave is debounced; save eagerly so a quick kill or crash
  /// right after an edit doesn't drop it.
  private func save() {
    try? context.save()
  }

}

private struct ProgressSummary: View {
  let done: Int
  let total: Int

  private var fraction: Double { total == 0 ? 0 : Double(done) / Double(total) }

  var body: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle().stroke(.tint.opacity(0.18), lineWidth: 5)
        Circle()
          .trim(from: 0, to: fraction)
          .stroke(.tint, style: StrokeStyle(lineWidth: 5, lineCap: .round))
          .rotationEffect(.degrees(-90))
      }
      .frame(width: 34, height: 34)
      .animation(.snappy, value: fraction)

      VStack(alignment: .leading, spacing: 2) {
        Text(headline)
          .font(.headline)
          .contentTransition(.numericText())
        Text("\(done) of \(total) completed")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .contentTransition(.numericText())
      }
      .animation(.snappy, value: done)
      Spacer()
    }
    .accessibilityElement(children: .combine)
  }

  private var headline: String {
    switch total - done {
    case 0: "Everything's done"
    case 1: "1 thing left"
    case let n: "\(n) things left"
    }
  }
}
