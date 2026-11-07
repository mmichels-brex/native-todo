import SwiftUI

/// Bottom-pinned field for adding to-dos. Stays focused after submit so you can
/// add several in a row.
struct TodoComposer: View {
  let onAdd: (String) -> Void

  @State private var text = ""
  @FocusState private var isFocused: Bool
  @State private var addTick = 0

  private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "plus.circle.fill")
        .font(.title2)
        .foregroundStyle(.tint)
        .symbolEffect(.bounce, value: addTick)

      TextField("New To-Do", text: $text)
        .focused($isFocused)
        .submitLabel(.next)
        .onSubmit(submit)

      if !trimmed.isEmpty {
        Button(action: submit) {
          Image(systemName: "arrow.up.circle.fill")
            .font(.title2)
        }
        .accessibilityLabel("Add to-do")
        .transition(.scale.combined(with: .opacity))
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .composerBackground()
    .padding(.horizontal, 16)
    .padding(.bottom, 8)
    .animation(.snappy, value: trimmed.isEmpty)
    .sensoryFeedback(.impact(weight: .light), trigger: addTick)
  }

  private func submit() {
    guard !trimmed.isEmpty else {
      isFocused = false
      return
    }
    onAdd(trimmed)
    text = ""
    addTick += 1
    // Return resigns the field after onSubmit runs; take focus back on the
    // next runloop turn so the keyboard stays up for rapid entry.
    DispatchQueue.main.async { isFocused = true }
  }
}

private extension View {
  @ViewBuilder
  func composerBackground() -> some View {
    if #available(iOS 26, *) {
      glassEffect(.regular.interactive(), in: .capsule)
    } else {
      background(.regularMaterial, in: .capsule)
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
  }
}

#Preview("Composer") {
  VStack {
    Spacer()
    TodoComposer(onAdd: { print("Added:", $0) })
  }
  .background(Color(.systemGroupedBackground))
}
