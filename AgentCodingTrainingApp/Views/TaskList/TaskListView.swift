import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel(
        taskRepository: TaskRepository(),
        filterRepository: FilterRepository()
    )
    @State private var isShowingAddTask = false
    @State private var taskToEdit: TodoTask?
    @State private var taskToDelete: TodoTask?
    @State private var isShowingFilterSelection = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("タスク")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingAddTask = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
        .task {
            await viewModel.fetchAll()
        }
        .sheet(isPresented: $isShowingAddTask) {
            AddTaskView {
                Task { await viewModel.fetchAll() }
            }
        }
        .sheet(item: $taskToEdit) { task in
            // PR #4 で実装
            Text("タスク編集")
        }
        .sheet(isPresented: $isShowingFilterSelection) {
            // PR #5 で実装
            Text("フィルター選択")
        }
        .alert("タスクを削除しますか？", isPresented: .init(
            get: { taskToDelete != nil },
            set: { if !$0 { taskToDelete = nil } }
        )) {
            Button("削除", role: .destructive) {
                if let task = taskToDelete {
                    taskToDelete = nil
                    Task { await viewModel.deleteTask(id: task.id) }
                }
            }
            Button("キャンセル", role: .cancel) {
                taskToDelete = nil
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("読み込み中...")
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "エラー",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else {
            taskList
        }
    }

    private var taskList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                filterButton
                VStack(spacing: 12) {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskListItemView(
                            task: task,
                            onToggleComplete: {
                                Task { await viewModel.toggleComplete(task) }
                            },
                            onEdit: { taskToEdit = task },
                            onDelete: { taskToDelete = task }
                        )
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var filterButton: some View {
        Button {
            isShowingFilterSelection = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal")
                Text(viewModel.filter.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 13)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .accessibilityIdentifier("filter-button")
    }
}

private struct TaskListItemView: View {
    let task: TodoTask
    let onToggleComplete: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundStyle(task.isCompleted ? Color.blue : Color(.systemGray3))
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("toggle-complete-\(task.id)")

            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : Color(hex: "#101828"))

                if !task.memo.isEmpty {
                    Text(task.memo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                PriorityTagView(priority: task.priority, isCompleted: task.isCompleted)
            }

            Spacer()

            Menu {
                Button("編集", action: onEdit)
                Button("削除", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .frame(width: 48, height: 48)
            }
            .accessibilityIdentifier("menu-\(task.id)")
        }
        .padding(17)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

private struct PriorityTagView: View {
    let priority: Priority
    let isCompleted: Bool

    var body: some View {
        Text(priority.label)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isCompleted ? Color(.systemGray5) : priority.tagBackgroundColor)
            .foregroundStyle(isCompleted ? .primary : priority.tagForegroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private extension Filter {
    var label: String {
        switch self {
        case .all:        return "すべて"
        case .incomplete: return "未完了"
        case .completed:  return "完了済み"
        }
    }
}

private extension Priority {
    var label: String {
        switch self {
        case .high:   return "優先度 高"
        case .medium: return "優先度 中"
        case .low:    return "優先度 低"
        }
    }

    var tagBackgroundColor: Color {
        switch self {
        case .high:   return Color(hex: "#ffe2e2")
        case .medium: return Color(hex: "#fff0b3")
        case .low:    return Color(.systemGray5)
        }
    }

    var tagForegroundColor: Color {
        switch self {
        case .high:   return Color(hex: "#c10007")
        case .medium: return Color(hex: "#806300")
        case .low:    return .primary
        }
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8) & 0xff) / 255
        let b = Double(int & 0xff) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    TaskListView()
}
