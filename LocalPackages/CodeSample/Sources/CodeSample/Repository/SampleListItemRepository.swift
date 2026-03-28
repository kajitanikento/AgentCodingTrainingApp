import Foundation

public protocol SampleListItemRepository: Sendable {
    func fetchItems() async throws -> [SampleListItem]
    func fetchItem(id: UUID) async throws -> SampleListItem
}

public enum SampleListItemRepositoryError: Error, LocalizedError {
    case fetchFailed

    public var errorDescription: String? {
        switch self {
        case .fetchFailed: return "アイテムの取得に失敗しました"
        }
    }
}
