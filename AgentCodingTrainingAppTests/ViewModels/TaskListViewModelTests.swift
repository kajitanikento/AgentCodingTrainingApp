import Foundation
import Testing
@testable import AgentCodingTrainingApp

@Suite(.serialized)
@MainActor
struct TaskListViewModelTests {
    private var taskRepository: MockTaskRepository
    private var filterRepository: MockFilterRepository
    private var sut: TaskListViewModel

    init() {
        taskRepository = MockTaskRepository()
        filterRepository = MockFilterRepository()
        sut = TaskListViewModel(
            taskRepository: taskRepository,
            filterRepository: filterRepository
        )
    }

    /// フィルターが .all のとき
    /// 期待値: 完了済みを含む全タスクが表示される
    @Test func testFilterAllShowsAllTasks() async {
        taskRepository.stubbedTasks = [
            TodoTask(title: "未完了タスク", isCompleted: false),
            TodoTask(title: "完了済みタスク", isCompleted: true)
        ]
        filterRepository.stubbedFilter = .all

        await sut.fetchAll()

        #expect(sut.filteredTasks.count == 2)
    }

    /// フィルターが .incomplete のとき
    /// 期待値: 未完了タスクのみ表示される
    @Test func testFilterIncompleteShowsOnlyIncompleteTasks() async {
        taskRepository.stubbedTasks = [
            TodoTask(title: "未完了タスク", isCompleted: false),
            TodoTask(title: "完了済みタスク", isCompleted: true)
        ]
        filterRepository.stubbedFilter = .incomplete

        await sut.fetchAll()

        #expect(sut.filteredTasks.count == 1)
        #expect(sut.filteredTasks[0].isCompleted == false)
    }

    /// タスクを削除したとき
    /// 期待値: 一覧から該当タスクが消える
    @Test func testDeleteTask() async {
        let task = TodoTask(title: "削除するタスク")
        taskRepository.stubbedTasks = [task]
        await sut.fetchAll()

        await sut.deleteTask(id: task.id)

        #expect(sut.filteredTasks.count == 0)
    }

    /// 未完了タスクの完了をトグルしたとき
    /// 期待値: isCompleted が true になる
    @Test func testToggleTaskComplete() async {
        let task = TodoTask(title: "未完了タスク", isCompleted: false)
        taskRepository.stubbedTasks = [task]
        await sut.fetchAll()

        await sut.toggleComplete(task)

        #expect(sut.tasks[0].isCompleted == true)
    }

    /// フィルターを選択したとき
    /// 期待値: FilterRepository に保存が呼ばれる
    @Test func testFilterPersistsAfterSelection() async {
        await sut.fetchAll()

        await sut.selectFilter(.incomplete)

        #expect(filterRepository.savedFilter == .incomplete)
    }
}
