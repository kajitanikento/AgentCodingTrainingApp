import Foundation

final class TaskRepository: TaskRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let key = "tasks"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchAll() async throws -> [TodoTask] {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }
        do {
            return try JSONDecoder().decode([TodoTask].self, from: data)
        } catch {
            throw TaskRepositoryError.loadFailed
        }
    }

    func save(_ task: TodoTask) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        var tasks = (try? await fetchAllWithoutDelay()) ?? []
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: key)
        } catch {
            throw TaskRepositoryError.saveFailed
        }
    }

    func delete(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        var tasks = (try? await fetchAllWithoutDelay()) ?? []
        tasks.removeAll { $0.id == id }
        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: key)
        } catch {
            throw TaskRepositoryError.deleteFailed
        }
    }

    private func fetchAllWithoutDelay() async throws -> [TodoTask] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }
        do {
            return try JSONDecoder().decode([TodoTask].self, from: data)
        } catch {
            throw TaskRepositoryError.loadFailed
        }
    }
}
