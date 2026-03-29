import XCTest

final class AddTaskViewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITEST_SEED_DATA"] = "1"
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    /// [CoreCase]
    /// +ボタンからタスクを作成して一覧に追加されることを確認する
    /// 期待値: 入力したタイトルのタスクが一覧に表示される
    func testCreateTask() {
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 5))

        // +ボタンをタップ
        app.navigationBars["タスク"].buttons["plus"].tap()
        XCTAssertTrue(app.navigationBars["タスク追加"].waitForExistence(timeout: 3))

        // タイトルを入力
        let titleField = app.textFields["title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("テスト買い物リスト")

        // 優先度を選択
        let priorityPicker = app.segmentedControls["priority-picker"]
        XCTAssertTrue(priorityPicker.waitForExistence(timeout: 3))
        priorityPicker.buttons["高"].tap()

        // メモを入力
        let memoField = app.textFields["memo-field"]
        if memoField.waitForExistence(timeout: 2) {
            memoField.tap()
            memoField.typeText("スーパーで購入する")
        }

        // 保存ボタンをタップ
        let saveButton = app.buttons["save-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // 一覧にタスクが追加されることを確認
        XCTAssertTrue(app.staticTexts["テスト買い物リスト"].waitForExistence(timeout: 5))
    }

    /// [CoreCase]
    /// タイトルが空のとき保存ボタンが非活性であることを確認する
    /// 期待値: 保存ボタンが非活性、キャンセルで一覧に戻れる
    func testSaveButtonDisabledWithEmptyTitle() {
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 5))

        // +ボタンをタップ
        app.navigationBars["タスク"].buttons["plus"].tap()
        XCTAssertTrue(app.navigationBars["タスク追加"].waitForExistence(timeout: 3))

        // 保存ボタンが非活性であることを確認
        let saveButton = app.buttons["save-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertFalse(saveButton.isEnabled)

        // キャンセルをタップして一覧に戻る
        app.buttons["キャンセル"].tap()
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 3))
    }
}
