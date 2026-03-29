import Foundation

final class FilterRepository: FilterRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let key = "filter"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchFilter() async throws -> Filter {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard let rawValue = userDefaults.string(forKey: key),
              let filter = Filter(rawValue: rawValue) else {
            return .all
        }
        return filter
    }

    func save(_ filter: Filter) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        userDefaults.set(filter.rawValue, forKey: key)
    }
}
