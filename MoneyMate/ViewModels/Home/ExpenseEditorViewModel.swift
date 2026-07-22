//
//  ExpenseEditorViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/3.
//

import Foundation
import Observation
import SwiftData

/// 管理新增記帳表單的輸入、驗證與儲存狀態。
@MainActor
@Observable
final class ExpenseEditorViewModel {
    /// 儲存表單結果的記帳資料介面。
    private let repository: any ExpenseRepositoryProtocol

    /// 建立使用指定 repository 的空白記帳表單。
    /// - Parameter repository: 儲存新記帳的資料介面。
    init(repository: any ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    /// 使用者輸入的金額文字，最多保留十個字元並同步解析至 `amount`。
    var amountText: String = "" {
        didSet {
            // 表單規格限制金額最多輸入十個字元。
            if amountText.count > 10 {
                amountText = String(amountText.prefix(10))
                return
            }

            guard !amountText.isEmpty else {
                amount = nil
                return
            }

            if let intValue = Int(amountText) {
                amount = intValue
            } else {
                amount = nil
            }
        }
    }

    /// 尚未套用收支正負號的使用者輸入金額。
    var amount: Int? = nil

    /// 使用者選擇的記帳分類。
    var category: Category = .dining

    /// 使用者選擇的收入或支出類型。
    var type: TransactionType = .expenditure

    /// 使用者選擇的記帳日期與時間。
    var date: Date = Date()

    /// 使用者輸入的備註，最多保留十個字元。
    var remark: String = "" {
        didSet {
            if remark.count > 10 {
                remark = String(remark.prefix(10))
            }
        }
    }

    /// 是否正在等待 repository 完成儲存。
    private(set) var isSaving = false

    /// 控制儲存失敗提示是否顯示。
    var isShowingSaveError = false

    /// 表單是否具備正整數金額與非空白備註，可以進行儲存。
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

    /// 將表單轉換成符合正負號 convention 的 `Expense` 並儲存。
    /// - Returns: 儲存成功時回傳 `true`；輸入無效或 repository 拋錯時回傳 `false`。
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
