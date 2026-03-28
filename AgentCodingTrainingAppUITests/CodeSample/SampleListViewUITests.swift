import XCTest

final class SampleListViewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--screen", "--list"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    /// [CoreCase]
    /// SampleListViewが起動したとき、ナビゲーションタイトルとリストのセルが表示される
    /// 期待値: "リスト一覧" ナビバーが存在し、リストのセルが1件以上表示されている
    func testSampleListViewLaunch() {
        XCTAssertTrue(app.navigationBars["リスト一覧"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5))

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SampleListView_Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// [CoreCase]
    /// 先頭のセルをタップしたとき、SampleDetailViewに遷移する
    /// 期待値: タップしたセルのタイトルと一致するナビゲーションバーが表示される
    func testNavigateToSampleDetail() {
        XCTAssertTrue(app.navigationBars["リスト一覧"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5))

        let firstCell = app.cells.firstMatch
        let cellTitle = firstCell.staticTexts.firstMatch.label
        firstCell.tap()

        XCTAssertTrue(app.navigationBars[cellTitle].waitForExistence(timeout: 5))

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SampleDetailView_Navigation"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
