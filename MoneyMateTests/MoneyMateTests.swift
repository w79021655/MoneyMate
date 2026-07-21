//
//  MoneyMateTests.swift
//  MoneyMateTests
//
//  Created by 吳駿 on 2025/5/2.
//

import Foundation
import Testing
@testable import MoneyMate
import SwiftData

struct MoneyMateTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    @MainActor
    @Test func repositoryUsesInjectedModelContextAndMonthInterval() async throws {
        let container = try ModelContainer(
            for: Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = ExpenseRepository(context: container.mainContext)
        let januaryDate = makeDate(year: 2026, month: 1, day: 15)
        let februaryDate = makeDate(year: 2026, month: 2, day: 1)

        try await repository.addExpense(makeExpense(amount: 550, date: januaryDate))
        try await repository.addExpense(makeExpense(amount: 900, date: februaryDate))

        let interval = try #require(calendar.dateInterval(of: .month, for: januaryDate))
        let result = try await repository.fetchExpenses(in: interval)

        #expect(result.count == 1)
        #expect(result.first?.amount == 550)
    }

    @MainActor
    @Test func homeUseCaseCalculatesAllRecordsInRequestedMonth() async throws {
        let januaryDate = makeDate(year: 2026, month: 1, day: 15)
        let februaryDate = makeDate(year: 2026, month: 2, day: 1)
        let januaryExpenses = (0..<25).map { index in
            makeExpense(
                amount: index.isMultiple(of: 2) ? 100 : -40,
                date: januaryDate
            )
        }
        let repository = MockExpenseRepository(
            expenses: januaryExpenses + [makeExpense(amount: 10_000, date: februaryDate)]
        )
        let useCase = HomeUseCase(repository: repository, calendar: calendar)

        let result = try await useCase.fetchMonthlySummary(for: januaryDate)

        #expect(result.income == 1_300)
        #expect(result.expense == -480)
        #expect(result.balance == 820)
    }

    @MainActor
    @Test func repositoryPaginationDoesNotSkipEqualTimestamps() async throws {
        let container = try ModelContainer(
            for: Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = ExpenseRepository(context: container.mainContext)
        let date = makeDate(year: 2026, month: 1, day: 15)
        let interval = try #require(calendar.dateInterval(of: .month, for: date))

        for index in 0..<25 {
            try await repository.addExpense(
                makeExpense(amount: index + 1, date: date)
            )
        }

        var cursor: ExpensePageCursor?
        var fetchedIDs: [UUID] = []

        repeat {
            let page = try await repository.fetchExpensePage(
                in: interval,
                after: cursor,
                limit: 10
            )
            fetchedIDs.append(contentsOf: page.expenses.map(\.id))
            cursor = page.hasMore ? page.nextCursor : nil
        } while cursor != nil

        #expect(fetchedIDs.count == 25)
        #expect(Set(fetchedIDs).count == 25)
    }

    @MainActor
    @Test func homeViewModelExposesFailureState() async {
        let repository = MockExpenseRepository()
        repository.shouldFail = true
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(useCase: useCase)

        await viewModel.refresh(for: makeDate(year: 2026, month: 1, day: 15))

        #expect(viewModel.loadState == .failed)
    }

    @MainActor
    @Test func editorReportsSaveFailureWithoutClaimingSuccess() async {
        let repository = MockExpenseRepository()
        repository.shouldFail = true
        let viewModel = ExpenseEditorViewModel(repository: repository)
        viewModel.amountText = "500"
        viewModel.remark = "測試"

        let succeeded = await viewModel.createExpense()

        #expect(!succeeded)
        #expect(viewModel.isShowingSaveError)
        #expect(repository.expenses.isEmpty)
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeExpense(amount: Int, date: Date) -> Expense {
        Expense(
            amount: amount,
            category: .dining,
            type: amount < 0 ? .expenditure : .income,
            date: date,
            dateTime: date,
            remark: "測試"
        )
    }
}
