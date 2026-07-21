//
//  HomeUseCase.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation
import SwiftData

struct MonthlySummary: Equatable {
    let income: Int
    let expense: Int

    var balance: Int { income + expense }
}

enum HomeUseCaseError: Error {
    case invalidMonthInterval
}

@MainActor
final class HomeUseCase {
    private let repository: any ExpenseRepositoryProtocol
    private let calendar: Calendar

    init(
        repository: any ExpenseRepositoryProtocol,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.repository = repository
        self.calendar = calendar
    }

    /// 回傳每月統計結果
    func fetchMonthlySummary(for date: Date) async throws -> MonthlySummary {
        let expenses = try await repository.fetchExpenses(in: monthInterval(containing: date))

        var income = 0
        var expense = 0

        for item in expenses {
            if item.amount > 0 {
                income += item.amount
            } else if item.amount < 0 {
                expense += item.amount
            }
        }

        return MonthlySummary(income: income, expense: expense)
    }

    func fetchMonthlyExpensePage(
        for date: Date,
        after cursor: ExpensePageCursor? = nil,
        limit: Int = 20
    ) async throws -> ExpensePage {
        try await repository.fetchExpensePage(
            in: monthInterval(containing: date),
            after: cursor,
            limit: limit
        )
    }

    func deleteExpense(_ id: PersistentIdentifier) async throws {
        try await repository.deleteByPersistentId(id)
    }

    private func monthInterval(containing date: Date) throws -> DateInterval {
        guard let interval = calendar.dateInterval(of: .month, for: date) else {
            throw HomeUseCaseError.invalidMonthInterval
        }

        return interval
    }
}
