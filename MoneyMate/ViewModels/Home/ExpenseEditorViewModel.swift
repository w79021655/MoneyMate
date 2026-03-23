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
            // 長度限制
            if amountText.count > 10 {
                amountText = String(amountText.prefix(10))
                return
            }

            // 空字串 = 尚未輸入
            guard !amountText.isEmpty else {
                amount = nil
                return
            }

            // 解析數字
            if let intValue = Int(amountText) {
                amount = intValue
            } else {
                amount = nil
            }
        }
    }

    @Published var amount: Int? = nil
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

    /// 是否可以送出
    var canSubmit: Bool {
        guard
            let amount,
            amount > 0,
            !remark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return false
        }
        return true
    }

    func createExpense() async {
        guard let amount = Int(amountText), amount > 0 else {
            return
        }

        let newExpense = Expense(
            amount: type == .expenditure ? -amount : amount,
            category: category,
            type: type,
            date: date,
            dateTime: dateTime,
            remark: remark
        )

        await repository.addExpense(newExpense)
    }
}
