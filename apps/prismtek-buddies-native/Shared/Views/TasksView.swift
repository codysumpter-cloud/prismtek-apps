import SwiftUI

/// Add / mark done / delete tasks. Persisted via AppState (@AppStorage JSON).
struct TasksView: View {
    @EnvironmentObject var appState: AppState
    @State private var newTitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks")
                .font(.headline)

            HStack {
                TextField("New task…", text: $newTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(add)
                Button("Add", action: add)
                    .buttonStyle(.borderedProminent)
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if appState.tasks.isEmpty {
                Text("No tasks yet. Bitbud is waiting.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            } else {
                List {
                    ForEach(appState.tasks) { task in
                        HStack {
                            Button {
                                appState.toggleDone(task)
                            } label: {
                                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isDone ? .green : .secondary)
                            }
                            .buttonStyle(.plain)

                            Text(task.title)
                                .strikethrough(task.isDone)
                                .foregroundStyle(task.isDone ? .secondary : .primary)
                            Spacer()
                            Button {
                                appState.deleteTask(task)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                #if os(macOS)
                .listStyle(.inset)
                #else
                .listStyle(.plain)
                #endif
            }
        }
        .padding()
    }

    private func add() {
        appState.addTask(newTitle)
        newTitle = ""
    }
}
