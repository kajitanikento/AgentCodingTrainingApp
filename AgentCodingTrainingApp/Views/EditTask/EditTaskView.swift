import SwiftUI

struct EditTaskView: View {
    @StateObject private var viewModel: EditTaskViewModel
    @Environment(\.dismiss) private var dismiss
    var onSaved: (() -> Void)?

    init(task: TodoTask, onSaved: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditTaskViewModel(
            task: task,
            repository: TaskRepository()
        ))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("タスク編集")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("キャンセル") { dismiss() }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("保存") {
                            Task {
                                let saved = await viewModel.save()
                                if saved {
                                    onSaved?()
                                    dismiss()
                                }
                            }
                        }
                        .disabled(!viewModel.isSaveEnabled)
                        .accessibilityIdentifier("save-button")
                    }
                }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                taskInfoSection
                prioritySection
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var taskInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タスク情報")
                .font(.callout)
                .foregroundStyle(Color(hex: "#4a5565"))
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("タスク名")
                            .font(.headline)
                        Text("必須")
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                    TextField("例: 牛乳を買う", text: $viewModel.title)
                        .font(.body)
                        .accessibilityIdentifier("title-field")
                }
                .padding(.horizontal, 17)
                .padding(.vertical, 17)

                Divider().padding(.leading, 17)

                VStack(alignment: .leading, spacing: 4) {
                    Text("メモ")
                        .font(.headline)
                    TextField("例: 近所のスーパーで購入する", text: $viewModel.memo, axis: .vertical)
                        .font(.body)
                        .lineLimit(4...)
                        .accessibilityIdentifier("memo-field")
                }
                .padding(.horizontal, 17)
                .padding(.vertical, 17)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("優先度")
                .font(.callout)
                .foregroundStyle(Color(hex: "#4a5565"))
                .padding(.horizontal, 16)

            Picker("優先度", selection: $viewModel.priority) {
                Text("低").tag(Priority.low)
                Text("中").tag(Priority.medium)
                Text("高").tag(Priority.high)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .accessibilityIdentifier("priority-picker")
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
    EditTaskView(task: TodoTask(title: "牛乳を買う", memo: "近所のスーパーで", priority: .high))
}
