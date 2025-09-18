//
//  MockExpenseRepository.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation
import SwiftData

final class MockExpenseRepository: ExpenseRepositoryProtocol {

    func addExpense(_ expense: Expense) async {
        await dataProviderHelper.insert(expense)
    }

    func deleteAll() async {
        await dataProviderHelper.deleteAll(of: Expense.self)
    }

    /// 取得指定起始日期往後抓取指定 20 筆數的資料
    func fetchExpenses(from startDate: Date) async -> [Expense] {
        let dataset: [Expense] = await dataProviderHelper.fetchPaginatedAfterDate(startDate: startDate)

        return dataset
    }

    func addTestData() async {
        guard let filePath = Bundle.main.path(forResource: "ExpensesList", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath), options: .alwaysMapped),
              let dic = data.dictionary,
              let content = dic["expense"] as? [Parameters],
              let outputData = content.data,
              let result = codableHelper.decode(from: outputData, type: [Expense].self) else {
            return
        }

        await deleteAll()
        
        for expense in result {
            await addExpense(expense)
        }
    }
}
