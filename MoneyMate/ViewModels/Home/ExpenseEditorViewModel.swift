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

    func createExpense() async {
        let newExpense = Expense(
            amount: amount,
            category: category,
            date: date,
            dateTime: dateTime,
            remark: remark
        )

        await repository.addExpense(newExpense)
    }
}
