import SwiftUI

struct TodoRow: View {
  @Bindable var item: TodoItem
  let onToggle: () -> Void
  let onDelete: () -> Void

  @FocusState private var isEditing: Bool
  @State private var draft = ""

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Button(action: onToggle) {
        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
          .font(.title2)
          .foregroundStyle(item.isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
          .contentTransition(.symbolEffect(.replace))
          .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 6 }
      }
      .buttonStyle(.plain)
      .accessibilityLabel(item.isDone ? "Mark as not done" : "Mark as done")

      VStack(alignment: .leading, spacing: 3) {
        TextField("To-do", text: $draft, axis: .vertical)
          .focused($isEditing)
          .submitLabel(.done)
          .strikethrough(item.isDone && !isEditing, color: .secondary)
          .foregroundStyle(item.isDone ? .secondary : .primary)
          .onSubmit(commit)
          .onChange(of: draft) { _, newValue in
            // Vertical text fields insert newlines on return; treat return as "done".
            if newValue.contains("\n") {
              draft = newValue.replacingOccurrences(of: "\n", with: "")
              isEditing = false
            }
          }

        Text(subtitle)
          .font(.caption)
          .foregroundStyle(.tertiary)
      }
    }
    .padding(.vertical, 2)
    .onAppear { draft = item.title }
    .onChange(of: item.title) { _, newValue in
      if !isEditing { draft = newValue }
    }
    .onChange(of: isEditing) { _, editing in
      if !editing { commit() }
    }
  }

  private var subtitle: String {
    if let completedAt = item.completedAt {
      "Completed \(completedAt.formatted(.relative(presentation: .named)))"
    } else {
      "Added \(item.createdAt.formatted(.relative(presentation: .named)))"
    }
  }

  private func commit() {
    let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      onDelete()
    } else if trimmed != item.title {
      item.title = trimmed
      try? item.modelContext?.save()
      draft = trimmed
    } else {
      draft = trimmed
    }
  }
}

#Preview("Rows") {
  List {
    TodoRow(item: TodoItem(title: "Buy oat milk"), onToggle: {}, onDelete: {})
    TodoRow(item: TodoItem(title: "Ship the native experiment", isDone: true), onToggle: {}, onDelete: {})
    TodoRow(
      item: TodoItem(title: "A much longer to-do title that wraps onto a second line to check the layout"),
      onToggle: {}, onDelete: {})
  }
  .modelContainer(TodoStore.preview([]))
}
