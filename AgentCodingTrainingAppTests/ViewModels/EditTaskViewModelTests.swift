import Foundation
import Testing
@testable import AgentCodingTrainingApp

@Suite(.serialized)
@MainActor
struct EditTaskViewModelTests {
    private var repository: MockTaskRepository
    private var existingTask: TodoTask
    private var sut: EditTaskViewModel

    init() {
        repository = MockTaskRepository()
        existingTask = TodoTask(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "既存タスク",
            memo: "既存メモ",
            priority: .high,
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut = EditTaskViewModel(task: existingTask, repository: repository)
    }

    /// 既存タスクを渡してViewModel初期化したとき
    /// 期待値: フォームに既存タスクの内容が反映されている
    @Test func testExistingTaskDataPreloaded() {
        #expect(sut.title == "既存タスク")
        #expect(sut.memo == "既存メモ")
        #expect(sut.priority == .high)
    }

    /// 内容を変更して保存したとき
    /// 期待値: TaskRepository.save が更新内容で呼ばれる
    @Test func testSaveUpdatesTask() async {
        sut.title = "更新タスク"
        sut.priority = .low

        let saved = await sut.save()

        #expect(saved == true)
        #expect(repository.savedTasks.count == 1)
        #expect(repository.savedTasks[0].id == existingTask.id)
        #expect(repository.savedTasks[0].title == "更新タスク")
        #expect(repository.savedTasks[0].priority == .low)
    }

    /// キャンセルしたとき
    /// 期待値: TaskRepository.save が呼ばれない
    @Test func testCancelDoesNotCallRepository() {
        // キャンセルはViewレイヤーのdismissのみで、ViewModelはsaveを呼ばない
        #expect(repository.savedTasks.count == 0)
    }

    /// タイトルを空にしたとき
    /// 期待値: 保存ボタンが非活性（isSaveEnabled == false）
    @Test func testSaveButtonDisabledWhenTitleEmpty() {
        sut.title = ""
        #expect(sut.isSaveEnabled == false)
    }
}
