import Foundation
import Combine

@MainActor
final class EditTaskViewModel: ObservableObject {
    @Published var title: String {
        didSet { if title.count > 30 { title = String(title.prefix(30)) } }
    }
    @Published var memo: String {
        didSet { if memo.count > 100 { memo = String(memo.prefix(100)) } }
    }
    @Published var priority: Priority

    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let originalTask: TodoTask
    private let repository: any TaskRepositoryProtocol

    init(task: TodoTask, repository: some TaskRepositoryProtocol) {
        self.originalTask = task
        self.title = task.title
        self.memo = task.memo
        self.priority = task.priority
        self.repository = repository
    }

    func save() async -> Bool {
        isLoading = true
        errorMessage = nil
        var updated = originalTask
        updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.memo = memo
        updated.priority = priority
        updated.updatedAt = Date()
        do {
            try await repository.save(updated)
            isLoading = false
            return true
        } catch {
            errorMessage = "保存に失敗しました"
            isLoading = false
            return false
        }
    }
}
