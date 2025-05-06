//
//  ExpenseEditorViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/3.
//

import Foundation
import Combine
import SwiftData

/// 收入支出的 新增/編輯
class ExpenseEditorViewModel: ObservableObject {
    @Published var amount: Int = 0
    @Published var category: Category = .dining
    @Published var date: Date = Date()
    @Published var dateTime: Date = Date()
    @Published var remark: String = ""

    private var repository: ExpenseRepository?

    func configureIfNeeded(context: ModelContext) {
        guard repository == nil else { return }
        repository = ExpenseRepository(context: context)
    }

    func createExpense() {
        let newExpense = Expense(
            amount: amount,
            category: category,
            date: date,
            dateTime: dateTime,
            remark: remark
        )

        repository?.addExpense(newExpense)
    }

    func insertMockExpenses() {
        let today = Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print(formatter.string(from: today))

        let samples = [
            Expense(amount: -1200, category: .transport, date: today, dateTime: today, remark: "捷運悠遊卡"),
            Expense(amount: -350, category: .dining, date: today, dateTime: today, remark: "午餐便當"),
            Expense(amount: -900, category: .entertainment, date: today, dateTime: today, remark: "電影票"),
            Expense(amount: 3000, category: .salary, date: today, dateTime: today, remark: "接案收入"),
        ]

        for item in samples {
            repository?.addExpense(item)
        }
    }
}
