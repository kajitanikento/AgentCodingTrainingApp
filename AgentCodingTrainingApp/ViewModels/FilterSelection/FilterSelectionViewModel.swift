import Foundation
import Combine

@MainActor
final class FilterSelectionViewModel: ObservableObject {
    @Published private(set) var selectedFilter: Filter
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any FilterRepositoryProtocol

    init(currentFilter: Filter, repository: some FilterRepositoryProtocol) {
        self.selectedFilter = currentFilter
        self.repository = repository
    }

    func select(_ filter: Filter) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.save(filter)
            selectedFilter = filter
            isLoading = false
            return true
        } catch {
            errorMessage = "フィルターの保存に失敗しました"
            isLoading = false
            return false
        }
    }
}
