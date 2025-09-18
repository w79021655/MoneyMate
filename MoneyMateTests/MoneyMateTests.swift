//
//  MoneyMateTests.swift
//  MoneyMateTests
//
//  Created by 吳駿 on 2025/5/2.
//

import Foundation
import Testing
@testable import MoneyMate
import SwiftData

struct MoneyMateTests {

    @MainActor
    @Test func testInsertMockExpenses() async throws {
        // 建立 in-memory 的 SwiftData 容器
        let container = try ModelContainer(for: Expense.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = ModelContext(container)

        // 建立 ViewModel 並注入 context
        let viewModel = ExpenseEditorViewModel()
        
        // 執行插入假資料
        viewModel.insertMockExpenses()

        // 驗證是否寫入成功（你可以根據假資料的數量驗證）
        let expenses: [Expense] = dataProviderHelper.fetchThisMonth(startDate: Date())

        #expect(expenses.count == 4)

        // 驗證金額是否正確（例如收入 + 支出合計）
        let total = expenses.map(\.amount).reduce(0, +)
        #expect(total == 550)
    }
}
