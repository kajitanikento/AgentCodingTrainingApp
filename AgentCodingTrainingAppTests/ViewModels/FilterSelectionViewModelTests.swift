import Foundation
import Testing
@testable import AgentCodingTrainingApp

@Suite(.serialized)
@MainActor
struct FilterSelectionViewModelTests {
    private var repository: MockFilterRepository
    private var sut: FilterSelectionViewModel

    init() {
        repository = MockFilterRepository()
        repository.stubbedFilter = .incomplete
        sut = FilterSelectionViewModel(currentFilter: .incomplete, repository: repository)
    }

    /// 保存済みフィルターを渡してViewModel初期化したとき
    /// 期待値: そのフィルターが選択状態になっている
    @Test func testCurrentFilterIsPreselected() {
        #expect(sut.selectedFilter == .incomplete)
    }

    /// フィルターを選択したとき
    /// 期待値: FilterRepository.save が選択値で呼ばれる
    @Test func testSelectFilterSavesToRepository() async {
        let saved = await sut.select(.completed)

        #expect(saved == true)
        #expect(repository.savedFilter == .completed)
        #expect(sut.selectedFilter == .completed)
    }
}
