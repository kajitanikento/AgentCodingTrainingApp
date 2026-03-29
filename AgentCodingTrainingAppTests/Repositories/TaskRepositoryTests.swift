import Foundation
import Testing
@testable import AgentCodingTrainingApp

@Suite(.serialized)
struct TaskRepositoryTests {
    private var sut: TaskRepository
    private var userDefaults: UserDefaults

    init() {
        userDefaults = UserDefaults(suiteName: "test.todo.task")!
        userDefaults.removePersistentDomain(forName: "test.todo.task")
        sut = TaskRepository(userDefaults: userDefaults)
    }

    /// タスクを保存して取得したとき
    /// 期待値: 保存したタスクと同じ内容が返る
    @Test func testSaveAndFetchTask() async throws {
        let task = TodoTask(title: "テストタスク", memo: "メモ", priority: .high)

        try await sut.save(task)
        let result = try await sut.fetchAll()

        #expect(result.count == 1)
        #expect(result[0].id == task.id)
        #expect(result[0].title == task.title)
        #expect(result[0].memo == task.memo)
        #expect(result[0].priority == task.priority)
    }

    /// 複数タスクを保存して取得したとき
    /// 期待値: 保存した順に全タスクが返る
    @Test func testFetchAllReturnsMultipleTasks() async throws {
        let task1 = TodoTask(title: "タスク1")
        let task2 = TodoTask(title: "タスク2")
        let task3 = TodoTask(title: "タスク3")

        try await sut.save(task1)
        try await sut.save(task2)
        try await sut.save(task3)
        let result = try await sut.fetchAll()

        #expect(result.count == 3)
        #expect(result[0].id == task1.id)
        #expect(result[1].id == task2.id)
        #expect(result[2].id == task3.id)
    }

    /// タスクを削除したとき
    /// 期待値: 一覧からそのタスクが消える
    @Test func testDeleteTask() async throws {
        let task = TodoTask(title: "削除するタスク")
        try await sut.save(task)

        try await sut.delete(id: task.id)
        let result = try await sut.fetchAll()

        #expect(result.count == 0)
    }

    /// タスクを上書き保存したとき
    /// 期待値: 更新後の内容が返る
    @Test func testUpdateTask() async throws {
        var task = TodoTask(title: "元のタイトル")
        try await sut.save(task)

        task.title = "更新後のタイトル"
        try await sut.save(task)
        let result = try await sut.fetchAll()

        #expect(result.count == 1)
        #expect(result[0].title == "更新後のタイトル")
    }

    /// データが未保存のとき
    /// 期待値: 空配列が返る
    @Test func testFetchReturnsEmptyWhenNoData() async throws {
        let result = try await sut.fetchAll()

        #expect(result == [])
    }
}
