import XCTest

final class EditTaskViewUITests: XCTestCase {
    private let task1Id = "00000000-0000-0000-0000-000000000001"
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
    /// タスクの3点メニューから編集画面を開き、タイトルを変更して保存する
    /// 期待値: 一覧のタスクタイトルが変更後の内容に更新される
    func testEditTask() {
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["牛乳を買う"].waitForExistence(timeout: 5))

        // 3点メニューをタップ
        let menuButton = app.buttons["menu-\(task1Id)"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 3))
        menuButton.tap()

        // 「編集」を選択
        let editMenuItem = app.buttons["編集"]
        XCTAssertTrue(editMenuItem.waitForExistence(timeout: 3))
        editMenuItem.tap()

        XCTAssertTrue(app.navigationBars["タスク編集"].waitForExistence(timeout: 3))

        // タイトルをクリアして新しいタイトルを入力
        let titleField = app.textFields["title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.clearAndType("更新されたタスク名")

        // 保存ボタンをタップ
        let saveButton = app.buttons["save-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // 一覧のタスクタイトルが変更されていることを確認
        XCTAssertTrue(app.staticTexts["更新されたタスク名"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["牛乳を買う"].waitForExistence(timeout: 2))
    }
}

private extension XCUIElement {
    func clearAndType(_ text: String) {
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteString)
        typeText(text)
    }
}
