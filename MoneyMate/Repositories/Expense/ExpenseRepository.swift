//
//  ExpenseRepository.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import SwiftData

/// 使用注入的 `ModelContext` 執行記帳資料的新增、刪除與查詢。
///
/// 所有操作都在 Main Actor 上執行，避免將 SwiftData model 或 context 跨 actor 傳遞。
@MainActor
final class ExpenseRepository: ExpenseRepositoryProtocol {
    /// 由 composition root 注入、並由此 repository 專用的 SwiftData context。
    private let context: ModelContext

    /// 建立綁定指定 persistence context 的 repository。
    /// - Parameter context: 執行所有記帳資料操作的 `ModelContext`。
    init(context: ModelContext) {
        self.context = context
    }

    /// 新增一筆記帳並立即儲存 context。
    /// - Parameter expense: 要寫入 SwiftData store 的記帳資料。
    /// - Throws: Context 儲存失敗時回復未儲存變更並重新拋出錯誤。
    func addExpense(_ expense: Expense) async throws {
        context.insert(expense)
        try saveOrRollback()
    }

    /// 依 SwiftData persistent identifier 刪除記帳。
    /// - Parameter id: 目標記帳的 `PersistentIdentifier`；找不到資料時不執行動作。
    /// - Throws: Context 儲存失敗時回復未儲存變更並重新拋出錯誤。
    func deleteByPersistentId(_ id: PersistentIdentifier) async throws {
        guard let expense = context.model(for: id) as? Expense else {
            return
        }

        context.delete(expense)
        try saveOrRollback()
    }

    /// 刪除目前 context 可取得的所有記帳資料。
    /// - Throws: Fetch 或 context 儲存失敗時拋出錯誤。
    func deleteAll() async throws {
        let descriptor = FetchDescriptor<Expense>()
        let expenses = try context.fetch(descriptor)

        for expense in expenses {
            context.delete(expense)
        }

        try saveOrRollback()
    }

    /// 取得落在半開日期區間 `[start, end)` 內的所有記帳。
    /// - Parameter interval: 查詢的日期區間，結束時間不包含在結果內。
    /// - Returns: 符合日期條件的記帳資料；此 API 不保證排序。
    /// - Throws: SwiftData fetch 失敗時拋出錯誤。
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        let start = interval.start
        let end = interval.end
        let predicate = #Predicate<Expense> {
            $0.date >= start && $0.date < end
        }
        let descriptor = FetchDescriptor(predicate: predicate)

        return try context.fetch(descriptor)
    }

    /// 依日期與 UUID 的反向複合順序取得一頁記帳資料。
    ///
    /// 相同 timestamp 會再依 UUID 排序，避免跨頁時遺漏或重複資料。
    ///
    /// - Parameters:
    ///   - interval: 查詢的半開日期區間 `[start, end)`。
    ///   - cursor: 上一頁最後一筆資料的位置；`nil` 表示從第一頁開始。
    ///   - limit: 單頁最多回傳筆數；非正值會回傳空頁。
    /// - Returns: 當頁資料、下一頁 cursor 與是否仍有後續資料。
    /// - Throws: SwiftData fetch 失敗時拋出錯誤。
    func fetchExpensePage(
        in interval: DateInterval,
        after cursor: ExpensePageCursor?,
        limit: Int
    ) async throws -> ExpensePage {
        guard limit > 0 else {
            return ExpensePage(expenses: [], nextCursor: nil, hasMore: false)
        }

        let start = interval.start // 2026-06-30 16:00:00 UTC
        let end = interval.end // 2026-07-31 16:00:00 UTC
        let sort = [
            SortDescriptor(\Expense.date, order: .reverse),
            SortDescriptor(\Expense.id, order: .reverse)
        ]
        var descriptor: FetchDescriptor<Expense>

        if let cursor {
            let cursorDate = cursor.date
            let cursorID = cursor.id
            let predicate = #Predicate<Expense> {
                $0.date >= start &&
                $0.date < end &&
                ($0.date < cursorDate || ($0.date == cursorDate && $0.id < cursorID))
            }
            descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
        } else {
            let predicate = #Predicate<Expense> {
                $0.date >= start && $0.date < end
            }
            descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
        }

        descriptor.fetchLimit = limit + 1
        let fetched = try context.fetch(descriptor)
        let hasMore = fetched.count > limit
        let expenses = Array(fetched.prefix(limit))
        let nextCursor = expenses.last.map {
            ExpensePageCursor(date: $0.date, id: $0.id)
        }

        return ExpensePage(
            expenses: expenses,
            nextCursor: nextCursor,
            hasMore: hasMore
        )
    }

    /// 儲存目前 context，失敗時回復所有尚未儲存的變更。
    /// - Throws: `ModelContext.save()` 產生的錯誤。
    private func saveOrRollback() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
