import Foundation

@MainActor
public final class SampleListViewModel: ObservableObject {
    @Published public private(set) var items: [SampleListItem] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let repository: any SampleListItemRepository

    public init(repository: some SampleListItemRepository) {
        self.repository = repository
    }

    public func fetchItems() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await repository.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
