//
//  MockExpenseRepository.swift
//  MoneyMateTests
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation
import SwiftData
@testable import MoneyMate

/// 表示測試主動要求 mock repository 模擬失敗。
enum MockExpenseRepositoryError: Error {
    case requestedFailure
}

/// 在記憶體中模擬 `ExpenseRepositoryProtocol`，供 UseCase 與 ViewModel 測試隔離 persistence。
@MainActor
final class MockExpenseRepository: ExpenseRepositoryProtocol {
    /// Mock 目前持有的記帳資料。
    private(set) var expenses: [Expense]

    /// 設為 `true` 時，所有操作都會拋出 `requestedFailure`。
    var shouldFail = false

    /// 依查詢月份起始時間設定延遲，用來模擬請求回傳順序交錯。
    var fetchDelays: [Date: UInt64] = [:]

    /// 建立具有指定初始資料的 mock repository。
    /// - Parameter expenses: 測試開始時可查詢的記帳資料。
    init(expenses: [Expense] = []) {
        self.expenses = expenses
    }

    /// 模擬新增記帳，或依 `shouldFail` 拋出錯誤。
    func addExpense(_ expense: Expense) async throws {
        try throwIfNeeded()
        expenses.append(expense)
    }

    /// 模擬刪除所有記帳，或依 `shouldFail` 拋出錯誤。
    func deleteAll() async throws {
        try throwIfNeeded()
        expenses.removeAll()
    }

    /// 模擬依 persistent identifier 刪除記帳。
    func deleteByPersistentId(_ id: PersistentIdentifier) async throws {
        try throwIfNeeded()
        expenses.removeAll { $0.persistentModelID == id }
    }

    /// 模擬查詢半開日期區間 `[start, end)` 內的所有記帳。
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        try throwIfNeeded()
        try await delayIfNeeded(for: interval)
        return expenses.filter {
            $0.date >= interval.start && $0.date < interval.end
        }
    }

    /// 模擬取得所有記帳中最早的日期。
    func fetchEarliestExpenseDate() async throws -> Date? {
        try throwIfNeeded()
        return expenses.map(\.date).min()
    }

    /// 模擬取得所有記帳中最晚的日期。
    func fetchLatestExpenseDate() async throws -> Date? {
        try throwIfNeeded()
        return expenses.map(\.date).max()
    }

    /// 使用與 production repository 相同的日期與 UUID 複合順序模擬分頁。
    func fetchExpensePage(
        in interval: DateInterval,
        after cursor: ExpensePageCursor?,
        limit: Int
    ) async throws -> ExpensePage {
        try throwIfNeeded()
        try await delayIfNeeded(for: interval)

        let sorted = expenses
            .filter { expense in
                guard expense.date >= interval.start,
                      expense.date < interval.end else {
                    return false
                }

                guard let cursor else { return true }
                return expense.date < cursor.date ||
                    (expense.date == cursor.date && expense.id.uuidString < cursor.id.uuidString)
            }
            .sorted { lhs, rhs in
                if lhs.date == rhs.date {
                    return lhs.id.uuidString > rhs.id.uuidString
                }
                return lhs.date > rhs.date
            }

        let hasMore = sorted.count > limit
        let pageExpenses = Array(sorted.prefix(limit))
        let nextCursor = pageExpenses.last.map {
            ExpensePageCursor(date: $0.date, id: $0.id)
        }

        return ExpensePage(
            expenses: pageExpenses,
            nextCursor: nextCursor,
            hasMore: hasMore
        )
    }

    /// 在測試要求失敗時拋出固定錯誤。
    private func throwIfNeeded() throws {
        if shouldFail {
            throw MockExpenseRepositoryError.requestedFailure
        }
    }

    /// 依測試設定暫停指定月份的查詢。
    private func delayIfNeeded(for interval: DateInterval) async throws {
        guard let nanoseconds = fetchDelays[interval.start] else { return }
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
