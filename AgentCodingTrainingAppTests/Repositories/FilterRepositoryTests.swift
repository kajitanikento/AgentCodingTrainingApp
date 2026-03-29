import Foundation
import Testing
@testable import AgentCodingTrainingApp

@Suite(.serialized)
struct FilterRepositoryTests {
    private var sut: FilterRepository
    private var userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: "test.todo.filter")!
        userDefaults.removePersistentDomain(forName: "test.todo.filter")
        sut = FilterRepository(userDefaults: userDefaults)
    }

    /// フィルターを保存して取得したとき
    /// 期待値: 保存したフィルター値が返る
    @Test func testSaveAndFetchFilter() async throws {
        try await sut.save(.incomplete)
        let result = try await sut.fetchFilter()

        #expect(result == .incomplete)
    }

    /// フィルターが未保存のとき
    /// 期待値: .all が返る
    @Test func testDefaultFilterIsAll() async throws {
        let result = try await sut.fetchFilter()

        #expect(result == .all)
    }
}
