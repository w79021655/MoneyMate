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
@MainActor
class ExpenseEditorViewModel: ObservableObject {
    private var repository = ExpenseRepository()

    @Published var amountText: String = "" {
        didSet {
            if amountText.count > 10 {
                amountText = String(amountText.prefix(10))
            }

            if let intValue = Int(amountText) {
                amount = intValue
            } else {
                amount = 0
            }
        }
    }

    @Published var amount: Int = 0 {
        didSet {
            let newText = String(amount)
            if newText != amountText {
                amountText = newText
            }
        }
    }

    @Published var category: Category = .dining
    @Published var type: TransactionType = .expenditure
    @Published var date: Date = Date()
    @Published var dateTime: Date = Date()
    @Published var remark: String = "" {
        didSet {
            if remark.count > 10 {
                remark = String(remark.prefix(10))
            }
        }
    }

    func createExpense() async {
        guard let amount = Int(amountText), amount > 0 else {
            return
        }

        let newExpense = Expense(
            amount: amount,
            category: category,
            type: type,
            date: date,
            dateTime: dateTime,
            remark: remark
        )

        await repository.addExpense(newExpense)
    }
}
