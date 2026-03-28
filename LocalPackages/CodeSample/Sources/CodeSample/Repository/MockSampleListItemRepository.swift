import Foundation

public actor MockSampleListItemRepository: SampleListItemRepository {
    // UITestから起動画面を指定するときに使う固定ID
    public static let previewItemId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    public var stubbedItems: [SampleListItem] = [
        SampleListItem(id: previewItemId, title: "サンプルアイテム 1", isCompleted: false, createdAt: Date()),
        SampleListItem(id: UUID(), title: "サンプルアイテム 2", isCompleted: true, createdAt: Date()),
        SampleListItem(id: UUID(), title: "サンプルアイテム 3", isCompleted: false, createdAt: Date()),
    ]
    public var shouldThrow: Bool

    public init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    public func fetchItems() async throws -> [SampleListItem] {
        if shouldThrow { throw SampleListItemRepositoryError.fetchFailed }
        return stubbedItems
    }

    public func fetchItem(id: UUID) async throws -> SampleListItem {
        if shouldThrow { throw SampleListItemRepositoryError.fetchFailed }
        guard let item = stubbedItems.first(where: { $0.id == id }) else {
            throw SampleListItemRepositoryError.fetchFailed
        }
        return item
    }
}
