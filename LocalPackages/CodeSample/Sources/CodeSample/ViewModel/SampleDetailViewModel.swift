import Foundation

@MainActor
public final class SampleDetailViewModel: ObservableObject {
    @Published public private(set) var item: SampleListItem?
    @Published public private(set) var isLoading = true
    @Published public private(set) var errorMessage: String?

    private let repository: any SampleListItemRepository
    private let itemId: UUID

    public init(itemId: UUID, repository: any SampleListItemRepository) {
        self.itemId = itemId
        self.repository = repository
    }

    public func fetchItem() async {
        isLoading = true
        errorMessage = nil
        do {
            item = try await repository.fetchItem(id: itemId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
