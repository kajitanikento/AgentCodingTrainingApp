import Foundation
import Combine

@MainActor
final class AddTaskViewModel: ObservableObject {
    @Published var title: String = "" {
        didSet { if title.count > 30 { title = String(title.prefix(30)) } }
    }
    @Published var memo: String = "" {
        didSet { if memo.count > 100 { memo = String(memo.prefix(100)) } }
    }
    @Published var priority: Priority = .medium
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let repository: any TaskRepositoryProtocol

    init(repository: some TaskRepositoryProtocol) {
        self.repository = repository
    }

    func save() async -> Bool {
        isLoading = true
        errorMessage = nil
        let task = TodoTask(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            memo: memo,
            priority: priority
        )
        do {
            try await repository.save(task)
            isLoading = false
            return true
        } catch {
            errorMessage = "保存に失敗しました"
            isLoading = false
            return false
        }
    }
}
