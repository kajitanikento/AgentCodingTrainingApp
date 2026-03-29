import Foundation
import Testing
@testable import AgentCodingTrainingApp

@Suite(.serialized)
@MainActor
struct AddTaskViewModelTests {
    private var repository: MockTaskRepository
    private var sut: AddTaskViewModel

    init() {
        repository = MockTaskRepository()
        sut = AddTaskViewModel(repository: repository)
    }

    /// タイトルが空文字のとき
    /// 期待値: 保存ボタンが非活性（isSaveEnabled == false）
    @Test func testSaveButtonDisabledWhenTitleEmpty() {
        sut.title = ""
        #expect(sut.isSaveEnabled == false)
    }

    /// タイトルが空白のみのとき
    /// 期待値: 保存ボタンが非活性（isSaveEnabled == false）
    @Test func testSaveButtonDisabledWhenTitleWhitespaceOnly() {
        sut.title = "   "
        #expect(sut.isSaveEnabled == false)
    }

    /// タイトルが有効な文字列のとき
    /// 期待値: 保存ボタンが活性（isSaveEnabled == true）
    @Test func testSaveButtonEnabledWhenTitleValid() {
        sut.title = "買い物"
        #expect(sut.isSaveEnabled == true)
    }

    /// タイトルに31文字入力したとき
    /// 期待値: タイトルが30文字に切り詰められる
    @Test func testTitleCannotExceed30Characters() {
        sut.title = String(repeating: "あ", count: 31)
        #expect(sut.title.count == 30)
    }

    /// メモに101文字入力したとき
    /// 期待値: メモが100文字に切り詰められる
    @Test func testMemoCannotExceed100Characters() {
        sut.memo = String(repeating: "あ", count: 101)
        #expect(sut.memo.count == 100)
    }

    /// ViewModel初期化時
    /// 期待値: 優先度が .medium になっている
    @Test func testDefaultPriorityIsMedium() {
        #expect(sut.priority == .medium)
    }

    /// 有効なタイトルで保存したとき
    /// 期待値: TaskRepository.save が呼ばれる
    @Test func testSaveTaskCallsRepository() async {
        sut.title = "買い物"
        let saved = await sut.save()
        #expect(saved == true)
        #expect(repository.savedTasks.count == 1)
        #expect(repository.savedTasks[0].title == "買い物")
    }
}
