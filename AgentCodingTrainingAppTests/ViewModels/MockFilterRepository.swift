import Foundation
@testable import AgentCodingTrainingApp

final class MockFilterRepository: FilterRepositoryProtocol {
    var stubbedFilter: Filter = .all
    var savedFilter: Filter?
    var shouldThrow = false

    func fetchFilter() async throws -> Filter {
        if shouldThrow { throw FilterRepositoryError.loadFailed }
        return stubbedFilter
    }

    func save(_ filter: Filter) async throws {
        if shouldThrow { throw FilterRepositoryError.saveFailed }
        savedFilter = filter
    }
}
