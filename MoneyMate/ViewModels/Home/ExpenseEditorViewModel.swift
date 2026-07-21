//
//  ExpenseEditorViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/3.
//

import Foundation
import Observation
import SwiftData

/// 收入支出的 新增/編輯
@MainActor
@Observable
final class ExpenseEditorViewModel {
    private let repository: any ExpenseRepositoryProtocol

    init(repository: any ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    var amountText: String = "" {
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

    var amount: Int? = nil
    var category: Category = .dining
    var type: TransactionType = .expenditure
    var date: Date = Date()
    var remark: String = "" {
        didSet {
            if remark.count > 10 {
                remark = String(remark.prefix(10))
            }
        }
    }

    private(set) var isSaving = false
    var isShowingSaveError = false

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

    func createExpense() async -> Bool {
        guard let amount = Int(amountText), amount > 0 else {
            return false
        }

        isSaving = true
        isShowingSaveError = false
        defer { isSaving = false }

        let newExpense = Expense(
            amount: type == .expenditure ? -amount : amount,
            category: category,
            type: type,
            date: date,
            dateTime: date,
            remark: remark
        )

        do {
            try await repository.addExpense(newExpense)
            return true
        } catch {
            isShowingSaveError = true
            return false
        }
    }
}
