import XCTest

final class SampleDetailViewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    /// [CoreCase]
    /// SampleDetailViewが起動したとき、アイテムの詳細が表示される
    /// 期待値: アイテムタイトルが大タイトルとして表示され、コンテンツのセクションが存在する
    func testSampleDetailViewLaunch() {
        app = XCUIApplication()
        app.launchArguments = ["--screen", "--detail"]
        app.launch()

        XCTAssertTrue(app.staticTexts["サンプルアイテム 1"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["ステータス"].waitForExistence(timeout: 5))

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SampleDetailView_Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// [CoreCase]
    /// データ取得に失敗したとき、エラー画面が表示される
    /// 期待値: エラーメッセージが画面に表示される
    func testSampleDetailViewFetchError() {
        app = XCUIApplication()
        app.launchArguments = ["--screen", "--detail-error"]
        app.launch()

        XCTAssertTrue(app.staticTexts["エラー"].waitForExistence(timeout: 10))

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SampleDetailView_FetchError"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
