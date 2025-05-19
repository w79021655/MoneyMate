//
//  HomeUseCase.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation
import SwiftData

final class HomeUseCase {
    private var repository = ExpenseRepository()

    /// 回傳每月統計結果
    func fetchMonthlySummary(for date: Date) -> (income: Int, expense: Int, balance: Int) {
        let expenses = repository.fetchExpenses(from: date)

        let income = expenses.filter { $0.amount > 0 }.map(\.amount).reduce(0, +)
        let expense = expenses.filter { $0.amount < 0 }.map(\.amount).reduce(0, +)

        let balance = income + expense
        return (income, expense, balance)
    }

    /// 取得指定起始日期往後抓取指定 20 筆數的資料
    func fetchMonthlyExpense(for date: Date) -> [Expense] {
        let expenses = repository.fetchExpenses(from: date)
        return expenses
    }
}
