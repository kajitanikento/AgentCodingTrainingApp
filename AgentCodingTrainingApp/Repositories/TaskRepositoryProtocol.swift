import Foundation

protocol TaskRepositoryProtocol {
    func fetchAll() async throws -> [TodoTask]
    func save(_ task: TodoTask) async throws
    func delete(id: UUID) async throws
}
