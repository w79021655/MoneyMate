//
//  ExpenseDraft.swift
//  MoneyMate
//

import Foundation

/// ExpenseEditor feature 擁有的值型別 Model，封裝輸入限制與建立持久化模型的規則。
struct ExpenseDraft: Equatable {
    /// 使用者輸入的金額文字，最多保留十個字元。
    var amountText = "" {
        didSet {
            if amountText.count > 10 {
                amountText = String(amountText.prefix(10))
            }
        }
    }

    /// 使用者選擇的記帳分類。
    var category: Category = .dining

    /// 使用者選擇的收入或支出類型。
    var type: TransactionType = .expenditure

    /// 使用者選擇的記帳日期與時間。
    var date = Date()

    /// 使用者輸入的備註，最多保留十個字元。
    var remark = "" {
        didSet {
            if remark.count > 10 {
                remark = String(remark.prefix(10))
            }
        }
    }

    /// 尚未套用收支正負號的有效正整數金額。
    var amount: Int? {
        guard let amount = Int(amountText), amount > 0 else {
            return nil
        }
        return amount
    }

    /// 草稿是否具備有效金額與非空白備註。
    var canSubmit: Bool {
        amount != nil &&
            !remark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 將有效草稿轉換成符合正負號 convention 的持久化模型。
    /// - Returns: 草稿有效時建立 `Expense`，否則回傳 `nil`。
    func makeExpense() -> Expense? {
        guard let amount, canSubmit else { return nil }

        return Expense(
            amount: type == .expenditure ? -amount : amount,
            category: category,
            type: type,
            date: date,
            dateTime: date,
            remark: remark
        )
    }
}
