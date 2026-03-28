import XCTest
@testable import CodeSample

@MainActor
final class SampleListViewModelTests: XCTestCase {
    private var repository: MockSampleListItemRepository!
    private var sut: SampleListViewModel!

    override func setUp() {
        super.setUp()
        repository = MockSampleListItemRepository()
        sut = SampleListViewModel(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    /// fetchItemsを呼んだとき、Repositoryが返すアイテム一覧がViewModelに反映される
    /// 期待値: items がリポジトリのstubbedItemsと一致する
    func testFetchItemsLoadsItemsFromRepository() async {
        await sut.fetchItems()

        XCTAssertEqual(sut.items, repository.stubbedItems)
    }

    /// fetchItemsを呼んだとき、成功後にisLoadingがfalseになる
    /// 期待値: isLoading == false
    func testFetchItemsSetsIsLoadingFalseAfterSuccess() async {
        await sut.fetchItems()

        XCTAssertEqual(sut.isLoading, false)
    }

    /// fetchItemsを呼んだとき、成功後にerrorMessageがnilである
    /// 期待値: errorMessage == nil
    func testFetchItemsHasNoErrorMessageOnSuccess() async {
        await sut.fetchItems()

        XCTAssertNil(sut.errorMessage)
    }

    /// Repositoryがエラーをthrowしたとき、errorMessageがセットされる
    /// 期待値: errorMessage == SampleListItemRepositoryError.fetchFailedのlocalizedDescription
    func testFetchItemsSetsErrorMessageOnFailure() async {
        repository.shouldThrow = true

        await sut.fetchItems()

        XCTAssertEqual(sut.errorMessage, SampleListItemRepositoryError.fetchFailed.localizedDescription)
    }

    /// Repositoryがエラーをthrowしたとき、itemsは空のまま
    /// 期待値: items == []
    func testFetchItemsKeepsItemsEmptyOnFailure() async {
        repository.shouldThrow = true

        await sut.fetchItems()

        XCTAssertEqual(sut.items, [])
    }

    /// Repositoryがエラーをthrowしたとき、isLoadingがfalseになる
    /// 期待値: isLoading == false
    func testFetchItemsSetsIsLoadingFalseAfterFailure() async {
        repository.shouldThrow = true

        await sut.fetchItems()

        XCTAssertEqual(sut.isLoading, false)
    }
}
