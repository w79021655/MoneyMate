//
//  ExpenseEditorModel.swift
//  MoneyMate
//

import Foundation
import Observation

/// 管理 ExpenseEditor feature 單次新增流程的草稿、儲存狀態與 persistence 操作。
@MainActor
@Observable
final class ExpenseEditorModel {
    /// 此次編輯流程獨立持有的表單草稿。
    var draft: ExpenseDraft

    /// 是否正在等待 Repository 完成儲存。
    private(set) var isSaving = false

    /// 控制儲存失敗提示是否顯示。
    var isShowingSaveError = false

    /// 儲存新記帳的資料介面。
    private let repository: any ExpenseRepositoryProtocol

    /// 建立一個具有獨立草稿的新增記帳 Model。
    /// - Parameters:
    ///   - repository: 儲存新記帳的資料介面。
    ///   - draft: 初始表單草稿，預設為空白草稿。
    init(
        repository: any ExpenseRepositoryProtocol,
        draft: ExpenseDraft = ExpenseDraft()
    ) {
        self.repository = repository
        self.draft = draft
    }

    /// 儲存有效草稿。
    /// - Returns: 儲存成功時回傳記帳日期；輸入無效、取消或失敗時回傳 `nil`。
    func save() async -> Date? {
        guard !isSaving, let expense = draft.makeExpense() else {
            return nil
        }

        isSaving = true
        isShowingSaveError = false
        defer { isSaving = false }

        do {
            try await repository.addExpense(expense)
            return expense.date
        } catch is CancellationError {
            return nil
        } catch {
            isShowingSaveError = true
            return nil
        }
    }
}
