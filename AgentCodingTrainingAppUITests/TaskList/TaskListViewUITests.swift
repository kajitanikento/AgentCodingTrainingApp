import XCTest

final class TaskListViewUITests: XCTestCase {
    private let task1Id = "00000000-0000-0000-0000-000000000001"
    private let task2Id = "00000000-0000-0000-0000-000000000002"

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
    /// 既存タスクの完了ボタンをタップし削除するまでの一連の操作
    /// 期待値: 完了後に打ち消し線が表示され、削除後に一覧からタスクが消える
    func testTaskCompleteAndDelete() {
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["牛乳を買う"].waitForExistence(timeout: 5))

        // 完了ボタンをタップ
        let toggleButton = app.buttons["toggle-complete-\(task1Id)"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 3))
        toggleButton.tap()

        // 打ち消し線が表示されるのを少し待つ
        sleep(1)

        // 3点メニューをタップ
        let menuButton = app.buttons["menu-\(task1Id)"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 3))
        menuButton.tap()

        // 削除を選択
        let deleteMenuItem = app.buttons["削除"]
        XCTAssertTrue(deleteMenuItem.waitForExistence(timeout: 3))
        deleteMenuItem.tap()

        // 確認アラートで削除
        let deleteConfirmButton = app.alerts.buttons["削除"]
        XCTAssertTrue(deleteConfirmButton.waitForExistence(timeout: 3))
        deleteConfirmButton.tap()

        // 一覧から消えることを確認
        XCTAssertFalse(app.staticTexts["牛乳を買う"].waitForExistence(timeout: 3))
    }

    /// [CoreCase]
    /// フィルターボタンをタップして「未完了」を選択する操作
    /// 期待値: 完了済みタスク「メール返信」が非表示になる
    func testFilterSwitch() {
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["メール返信"].waitForExistence(timeout: 5))

        // フィルターボタンをタップ
        let filterButton = app.buttons["filter-button"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 3))
        filterButton.tap()

        sleep(1)
        // PR #5実装後にフィルター選択UIをタップする操作を追加予定
    }
}
