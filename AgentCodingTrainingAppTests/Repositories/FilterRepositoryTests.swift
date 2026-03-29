import XCTest
@testable import AgentCodingTrainingApp

final class FilterRepositoryTests: XCTestCase {
    private var sut: FilterRepository!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "test.todo.filter")!
        userDefaults.removePersistentDomain(forName: "test.todo.filter")
        sut = FilterRepository(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "test.todo.filter")
        sut = nil
        userDefaults = nil
        super.tearDown()
    }

    /// フィルターを保存して取得したとき
    /// 期待値: 保存したフィルター値が返る
    func testSaveAndFetchFilter() async throws {
        try await sut.save(.incomplete)
        let result = try await sut.fetchFilter()

        XCTAssertEqual(result, .incomplete)
    }

    /// フィルターが未保存のとき
    /// 期待値: .all が返る
    func testDefaultFilterIsAll() async throws {
        let result = try await sut.fetchFilter()

        XCTAssertEqual(result, .all)
    }
}
