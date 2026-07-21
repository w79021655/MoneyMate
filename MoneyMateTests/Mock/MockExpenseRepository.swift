//
//  MockExpenseRepository.swift
//  MoneyMateTests
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation
import SwiftData
@testable import MoneyMate

enum MockExpenseRepositoryError: Error {
    case requestedFailure
}

@MainActor
final class MockExpenseRepository: ExpenseRepositoryProtocol {
    private(set) var expenses: [Expense]
    var shouldFail = false

    init(expenses: [Expense] = []) {
        self.expenses = expenses
    }

    func addExpense(_ expense: Expense) async throws {
        try throwIfNeeded()
        expenses.append(expense)
    }

    func deleteAll() async throws {
        try throwIfNeeded()
        expenses.removeAll()
    }

    func deleteByPersistentId(_ id: PersistentIdentifier) async throws {
        try throwIfNeeded()
        expenses.removeAll { $0.persistentModelID == id }
    }

    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        try throwIfNeeded()
        return expenses.filter {
            $0.date >= interval.start && $0.date < interval.end
        }
    }

    func fetchExpensePage(
        in interval: DateInterval,
        after cursor: ExpensePageCursor?,
        limit: Int
    ) async throws -> ExpensePage {
        try throwIfNeeded()

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

    private func throwIfNeeded() throws {
        if shouldFail {
            throw MockExpenseRepositoryError.requestedFailure
        }
    }
}
