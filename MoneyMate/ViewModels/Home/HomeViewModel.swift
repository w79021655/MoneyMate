//
//  HomeViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import Observation
import SwiftData

enum HomeLoadState: Equatable {
    case idle
    case loading
    case content
    case empty
    case failed
}

@MainActor
@Observable
final class HomeViewModel {
    private let useCase: HomeUseCase
    private let pageSize: Int
    private var nextCursor: ExpensePageCursor?
    private var hasNextPage = false
    private var refreshGeneration = 0

    init(useCase: HomeUseCase, pageSize: Int = 20) {
        self.useCase = useCase
        self.pageSize = pageSize
    }

    private(set) var displayedMonth = Date()
    private(set) var monthlyIncome = 0
    private(set) var monthlyExpense = 0
    private(set) var monthlyBalance = 0
    private(set) var expenses: [Expense] = []
    private(set) var loadState: HomeLoadState = .idle
    private(set) var isLoadingNextPage = false
    private(set) var hasPaginationError = false
    var isShowingOperationError = false

    func refresh(for date: Date) async {
        refreshGeneration += 1
        let generation = refreshGeneration

        displayedMonth = date
        loadState = .loading
        hasPaginationError = false
        isShowingOperationError = false
        isLoadingNextPage = false
        nextCursor = nil
        hasNextPage = false

        do {
            let summary = try await useCase.fetchMonthlySummary(for: date)
            try Task.checkCancellation()
            let page = try await useCase.fetchMonthlyExpensePage(
                for: date,
                limit: pageSize
            )
            try Task.checkCancellation()

            guard generation == refreshGeneration else { return }

            monthlyIncome = summary.income
            monthlyExpense = summary.expense
            monthlyBalance = summary.balance
            expenses = page.expenses
            nextCursor = page.nextCursor
            hasNextPage = page.hasMore
            loadState = expenses.isEmpty ? .empty : .content
        } catch is CancellationError {
            return
        } catch {
            guard generation == refreshGeneration else { return }
            loadState = expenses.isEmpty ? .failed : .content
            isShowingOperationError = !expenses.isEmpty
        }
    }

    func loadNextPageIfNeeded(currentExpenseID: UUID) async {
        guard currentExpenseID == expenses.last?.id,
              hasNextPage,
              !isLoadingNextPage,
              let requestedCursor = nextCursor else {
            return
        }

        isLoadingNextPage = true
        hasPaginationError = false
        defer { isLoadingNextPage = false }

        do {
            let page = try await useCase.fetchMonthlyExpensePage(
                for: displayedMonth,
                after: requestedCursor,
                limit: pageSize
            )
            try Task.checkCancellation()

            guard nextCursor == requestedCursor else { return }

            let existingIDs = Set(expenses.map(\.id))
            expenses.append(contentsOf: page.expenses.filter { !existingIDs.contains($0.id) })
            nextCursor = page.nextCursor
            hasNextPage = page.hasMore
        } catch is CancellationError {
            return
        } catch {
            hasPaginationError = true
        }
    }

    func retryNextPage() async {
        guard let lastID = expenses.last?.id else { return }
        await loadNextPageIfNeeded(currentExpenseID: lastID)
    }

    func delete(_ expense: Expense) async {
        do {
            try await useCase.deleteExpense(expense.persistentModelID)
            await refresh(for: displayedMonth)
        } catch {
            loadState = expenses.isEmpty ? .failed : .content
            isShowingOperationError = !expenses.isEmpty
        }
    }
}
