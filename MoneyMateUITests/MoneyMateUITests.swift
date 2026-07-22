//
//  MoneyMateUITests.swift
//  MoneyMateUITests
//
//  Created by 吳駿 on 2025/5/2.
//

import XCTest

/// 驗證 MoneyMate 的基本啟動流程與啟動效能。
final class MoneyMateUITests: XCTestCase {

    /// 在每個 UI Test 前設定遇到失敗立即停止。
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 保留每個 UI Test 結束後的清理入口。
    override func tearDownWithError() throws {
    }

    /// 驗證 App 可以完成基本啟動。
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    /// 量測 App 啟動流程的效能。
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
