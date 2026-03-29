import XCTest

final class FilterSelectionViewUITests: XCTestCase {
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
    /// フィルターボタンをタップしてフィルター選択シートを開き、「未完了」を選択して閉じる
    /// その後アプリを再起動したとき、フィルターが「未完了」のままになっている
    /// 期待値: 再起動後もフィルターが「未完了」で永続化されている
    func testFilterSelectionPersists() {
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 5))

        // フィルターボタンをタップしてシートを開く
        let filterButton = app.buttons["filter-button"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 3))
        filterButton.tap()

        // フィルター選択シートが表示される
        XCTAssertTrue(app.navigationBars["フィルター選択"].waitForExistence(timeout: 3))

        // 「未完了」を選択
        let incompleteOption = app.buttons["filter-option-incomplete"]
        XCTAssertTrue(incompleteOption.waitForExistence(timeout: 3))
        incompleteOption.tap()

        // シートを閉じる
        let closeButton = app.buttons["close-button"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3))
        closeButton.tap()

        // フィルターが「未完了」に変わっていることを確認
        XCTAssertTrue(app.staticTexts["未完了"].waitForExistence(timeout: 3))

        // アプリを再起動（シードなし）
        app.terminate()
        app.launchEnvironment = [:]
        app.launch()

        // 再起動後もフィルターが「未完了」のままであることを確認
        XCTAssertTrue(app.navigationBars["タスク"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["未完了"].waitForExistence(timeout: 5))
    }
}
