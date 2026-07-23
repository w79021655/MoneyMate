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

/// 驗證 MoneyMate persistence、首頁業務流程與編輯器錯誤狀態。
struct MoneyMateTests {
    /// 使用固定 UTC 時區，避免月份邊界因測試環境而改變。
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    /// 驗證畫面假資料固定產生 45 筆，並維持穩定識別與收支 convention。
    @MainActor
    @Test func mockExpenseDataProvidesDisplayableList() throws {
        let referenceDate = makeDate(year: 2026, month: 7, day: 15)
        let interval = try #require(calendar.dateInterval(of: .month, for: referenceDate))

        let expenses = MockExpenseData.makeExpenses(
            referenceDate: referenceDate,
            calendar: calendar
        )

        #expect(expenses.count == 45)
        #expect(Set(expenses.map(\.id)).count == 45)
        #expect(expenses.allSatisfy { interval.contains($0.date) })
        #expect(expenses.allSatisfy {
            switch $0.type {
            case .income: $0.amount > 0
            case .expenditure: $0.amount < 0
            }
        })
    }

    /// 驗證 repository 只使用注入的 in-memory context，並遵守月份區間。
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

    /// 驗證月統計涵蓋當月全部資料，且不受 repository 分頁大小影響。
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

    /// 驗證相同 timestamp 的資料可透過複合 cursor 完整分頁且不重複。
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

    /// 驗證首次載入失敗時首頁進入 failed state。
    @MainActor
    @Test func homeViewModelExposesFailureState() async {
        let repository = MockExpenseRepository()
        repository.shouldFail = true
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(useCase: useCase)

        await viewModel.refresh(for: makeDate(year: 2026, month: 1, day: 15))

        #expect(viewModel.loadState == .failed)
    }

    /// 驗證編輯器儲存失敗時顯示錯誤，且不宣告成功或新增資料。
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

    /// 使用測試固定的 calendar 建立日期。
    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// 建立符合金額正負號 convention 的測試記帳資料。
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
