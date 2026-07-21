//
//  ExpenseRepository.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import SwiftData

@MainActor
final class ExpenseRepository: ExpenseRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addExpense(_ expense: Expense) async throws {
        context.insert(expense)
        try saveOrRollback()
    }

    func deleteByPersistentId(_ id: PersistentIdentifier) async throws {
        guard let expense = context.model(for: id) as? Expense else {
            return
        }

        context.delete(expense)
        try saveOrRollback()
    }

    func deleteAll() async throws {
        let descriptor = FetchDescriptor<Expense>()
        let expenses = try context.fetch(descriptor)

        for expense in expenses {
            context.delete(expense)
        }

        try saveOrRollback()
    }

    func fetchExpenses(in interval: DateInterval) async throws -> [Expense] {
        let start = interval.start
        let end = interval.end
        let predicate = #Predicate<Expense> {
            $0.date >= start && $0.date < end
        }
        let descriptor = FetchDescriptor(predicate: predicate)

        return try context.fetch(descriptor)
    }

    func fetchExpensePage(
        in interval: DateInterval,
        after cursor: ExpensePageCursor?,
        limit: Int
    ) async throws -> ExpensePage {
        guard limit > 0 else {
            return ExpensePage(expenses: [], nextCursor: nil, hasMore: false)
        }

        let start = interval.start
        let end = interval.end
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

    private func saveOrRollback() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
