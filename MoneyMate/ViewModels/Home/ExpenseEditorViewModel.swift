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
}
