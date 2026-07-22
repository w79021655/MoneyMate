//
//  MoneyMateUITestsLaunchTests.swift
//  MoneyMateUITests
//
//  Created by 吳駿 on 2025/5/2.
//

import XCTest

/// 在每種目標 App UI configuration 下驗證啟動並保留畫面截圖。
final class MoneyMateUITestsLaunchTests: XCTestCase {

    /// 要求 XCTest 對每個目標 App UI configuration 執行一次測試。
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// 在每個啟動測試前設定遇到失敗立即停止。
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 啟動 App 並將當下畫面保存為永久測試附件。
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
