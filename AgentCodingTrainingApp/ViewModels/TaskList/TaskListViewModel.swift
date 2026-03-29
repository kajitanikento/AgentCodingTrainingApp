import Foundation
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []
    @Published private(set) var filter: Filter = .all
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var filteredTasks: [TodoTask] {
        switch filter {
        case .all:        return tasks
        case .incomplete: return tasks.filter { !$0.isCompleted }
        case .completed:  return tasks.filter { $0.isCompleted }
        }
    }

    private let taskRepository: any TaskRepositoryProtocol
    private let filterRepository: any FilterRepositoryProtocol

    init(taskRepository: some TaskRepositoryProtocol, filterRepository: some FilterRepositoryProtocol) {
        self.taskRepository = taskRepository
        self.filterRepository = filterRepository
    }

    func fetchAll() async {
        isLoading = true
        errorMessage = nil
        do {
            async let tasks = taskRepository.fetchAll()
            async let filter = filterRepository.fetchFilter()
            (self.tasks, self.filter) = try await (tasks, filter)
        } catch {
            errorMessage = "データを読み込めませんでした"
        }
        isLoading = false
    }

    func deleteTask(id: UUID) async {
        do {
            try await taskRepository.delete(id: id)
            tasks.removeAll { $0.id == id }
        } catch {
            errorMessage = "削除に失敗しました"
        }
    }

    func toggleComplete(_ task: TodoTask) async {
        var updated = task
        updated.isCompleted.toggle()
        updated.updatedAt = Date()
        do {
            try await taskRepository.save(updated)
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = updated
            }
        } catch {
            errorMessage = "更新に失敗しました"
        }
    }

    func selectFilter(_ newFilter: Filter) async {
        filter = newFilter
        do {
            try await filterRepository.save(newFilter)
        } catch {
            errorMessage = "フィルターの保存に失敗しました"
        }
    }
}
