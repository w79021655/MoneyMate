//
//  ExpenseRepository.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import SwiftData

final class ExpenseRepository: ExpenseRepositoryProtocol {

    func addExpense(_ expense: Expense) async {
        await dataProviderHelper.insert(expense)
    }

    func deleteAll() async {
        await dataProviderHelper.deleteAll(of: Expense.self)
    }

    /// 取得指定起始日期往後抓取指定 20 筆數的資料
    func fetchExpenses(from startDate: Date) async -> [Expense] {
        await dataProviderHelper.fetchPaginatedAfterDate(startDate: startDate)
    }

    func addTestData() async {}
}
