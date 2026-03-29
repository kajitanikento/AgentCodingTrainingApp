import Foundation

protocol FilterRepositoryProtocol {
    func fetchFilter() async throws -> Filter
    func save(_ filter: Filter) async throws
}
