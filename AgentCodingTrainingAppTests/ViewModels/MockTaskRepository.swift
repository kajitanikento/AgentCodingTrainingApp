import Foundation
@testable import AgentCodingTrainingApp

final class MockTaskRepository: TaskRepositoryProtocol {
    var stubbedTasks: [TodoTask] = []
    var savedTasks: [TodoTask] = []
    var deletedIds: [UUID] = []
    var shouldThrow = false

    func fetchAll() async throws -> [TodoTask] {
        if shouldThrow { throw TaskRepositoryError.loadFailed }
        return stubbedTasks
    }

    func save(_ task: TodoTask) async throws {
        if shouldThrow { throw TaskRepositoryError.saveFailed }
        if let index = savedTasks.firstIndex(where: { $0.id == task.id }) {
            savedTasks[index] = task
        } else {
            savedTasks.append(task)
        }
        if let index = stubbedTasks.firstIndex(where: { $0.id == task.id }) {
            stubbedTasks[index] = task
        } else {
            stubbedTasks.append(task)
        }
    }

    func delete(id: UUID) async throws {
        if shouldThrow { throw TaskRepositoryError.deleteFailed }
        deletedIds.append(id)
        stubbedTasks.removeAll { $0.id == id }
    }
}
