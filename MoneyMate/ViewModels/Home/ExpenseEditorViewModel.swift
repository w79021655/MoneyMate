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
    private var repository = ExpenseRepository()

    @Published var amount: Int = 0
    @Published var category: Category = .dining
    @Published var date: Date = Date()
    @Published var dateTime: Date = Date()
    @Published var remark: String = ""

    func createExpense() {
        let newExpense = Expense(
            amount: amount,
            category: category,
            date: date,
            dateTime: dateTime,
            remark: remark
        )

        repository.addExpense(newExpense)
    }

    func insertMockExpenses() {
        var expenses: [Expense] = []
        let categories: [Category] = [
            .dining, .transport, .entertainment, .salary, .shopping, .phone, .rental,
            .fruits, .car, .beauty, .insurance, .gift, .pets, .electronics
        ]
        let remarks = ["便當", "捷運", "電影票", "接案", "網購", "電話費",
                       "房租", "水果", "汽油", "美髮", "保險費", "生日禮物", "寵物飼料", "耳機"]

        for _ in 0..<50 {
            let dayOffset = Int.random(in: 0..<90)
            let monthOffset = Int.random(in: -2...0) // 從 3 月到 5 月
            let baseDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: baseDate) ?? Date()

            let amount = Bool.random() ? Int.random(in: 100...5000) : -Int.random(in: 100...5000)
            let category = categories.randomElement() ?? .dining
            let remark = remarks.randomElement() ?? "雜費"

            let expense = Expense(
                amount: amount,
                category: category,
                date: date,
                dateTime: date,
                remark: remark
            )

            expenses.append(expense)
        }

        for expense in expenses {
            repository.addExpense(expense)
        }
    }

    func deleteAll() {
        repository.deleteAll()
    }
}
