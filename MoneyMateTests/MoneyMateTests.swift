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

    /// 驗證畫面年月與年月日固定使用繁體中文排列。
    @Test func appDateFormatsUseTraditionalChineseOrder() {
        let date = makeDate(year: 2025, month: 8, day: 24)

        #expect(date.formatted(AppDateFormat.yearMonth) == "2025年8月")
        #expect(date.formatted(AppDateFormat.yearMonthDay) == "2025年8月24日")
    }

    /// 驗證畫面假資料涵蓋最近 14 個月並跨年，且維持穩定識別與收支 convention。
    @MainActor
    @Test func mockExpenseDataProvidesDisplayableList() throws {
        let referenceDate = makeDate(year: 2026, month: 7, day: 15)
        let currentMonth = try #require(
            calendar.dateInterval(of: .month, for: referenceDate)
        )
        let earliestExpectedMonth = makeDate(
            year: 2025,
            month: 6,
            day: 1
        )

        let expenses = MockExpenseData.makeExpenses(
            referenceDate: referenceDate,
            calendar: calendar
        )
        let coveredMonths = Set(expenses.map {
            let components = calendar.dateComponents(
                [.year, .month],
                from: $0.date
            )
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        })
        let coveredYears = Set(expenses.map {
            calendar.component(.year, from: $0.date)
        })

        #expect(expenses.count == MockExpenseData.expenseCount)
        #expect(Set(expenses.map(\.id)).count == MockExpenseData.expenseCount)
        #expect(coveredMonths.count == MockExpenseData.coveredMonthCount)
        #expect(coveredYears == [2025, 2026])
        #expect(expenses.map(\.date).min()! >= earliestExpectedMonth)
        #expect(
            expenses.filter { currentMonth.contains($0.date) }.count ==
                MockExpenseData.currentMonthExpenseCount
        )
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

    /// 驗證 repository 能取得最早與最晚記帳日期，空資料則回傳 nil。
    @MainActor
    @Test func repositoryFetchesExpenseDateBounds() async throws {
        let container = try ModelContainer(
            for: Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = ExpenseRepository(context: container.mainContext)
        let januaryDate = makeDate(year: 2026, month: 1, day: 15)
        let marchDate = makeDate(year: 2026, month: 3, day: 1)

        #expect(try await repository.fetchEarliestExpenseDate() == nil)
        #expect(try await repository.fetchLatestExpenseDate() == nil)

        try await repository.addExpense(makeExpense(amount: 100, date: marchDate))
        try await repository.addExpense(makeExpense(amount: -50, date: januaryDate))

        #expect(try await repository.fetchEarliestExpenseDate() == januaryDate)
        #expect(try await repository.fetchLatestExpenseDate() == marchDate)
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

    /// 驗證月份運算會正規化月底日期，並能正確跨年。
    @MainActor
    @Test func homeUseCaseNormalizesAndOffsetsMonthsAcrossYears() throws {
        let repository = MockExpenseRepository()
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let decemberEnd = makeDate(year: 2025, month: 12, day: 31)

        let decemberStart = try useCase.startOfMonth(containing: decemberEnd)
        let januaryStart = try useCase.month(byAdding: 1, to: decemberEnd)

        #expect(decemberStart == makeDate(year: 2025, month: 12, day: 1))
        #expect(januaryStart == makeDate(year: 2026, month: 1, day: 1))
    }

    /// 驗證非 UTC 時區仍使用注入 Calendar 建立正確的月份邊界。
    @MainActor
    @Test func homeUseCaseUsesInjectedTimeZoneForMonthBoundary() throws {
        var taipeiCalendar = Calendar(identifier: .gregorian)
        taipeiCalendar.timeZone = TimeZone(identifier: "Asia/Taipei")!
        let repository = MockExpenseRepository()
        let useCase = HomeUseCase(
            repository: repository,
            calendar: taipeiCalendar
        )
        let date = Date(timeIntervalSince1970: 1_767_225_600) // 2026-01-01 00:00 UTC
        let expected = taipeiCalendar.date(
            from: DateComponents(year: 2026, month: 1, day: 1)
        )

        #expect(try useCase.startOfMonth(containing: date) == expected)
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

    /// 驗證首頁月份操作遵守最早記帳月份與本月邊界。
    @MainActor
    @Test func homeViewModelNavigatesWithinSelectableMonthBounds() async {
        let januaryDate = makeDate(year: 2026, month: 1, day: 15)
        let marchDate = makeDate(year: 2026, month: 3, day: 15)
        let repository = MockExpenseRepository(expenses: [
            makeExpense(amount: 100, date: januaryDate),
            makeExpense(amount: -40, date: marchDate)
        ])
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { marchDate }
        )

        await viewModel.refresh(for: marchDate)
        #expect(!viewModel.canSelectNextMonth)
        #expect(viewModel.canSelectPreviousMonth)

        await viewModel.selectPreviousMonth()
        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 2, day: 1))
        #expect(viewModel.loadState == .empty)

        await viewModel.selectPreviousMonth()
        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 1, day: 1))
        #expect(!viewModel.canSelectPreviousMonth)

        await viewModel.selectPreviousMonth()
        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 1, day: 1))

        await viewModel.selectMonth(makeDate(year: 2026, month: 12, day: 1))
        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 3, day: 1))
    }

    /// 驗證沒有任何資料時，月份範圍只包含本月。
    @MainActor
    @Test func homeViewModelUsesCurrentMonthAsOnlyBoundWhenEmpty() async {
        let currentDate = makeDate(year: 2026, month: 7, day: 23)
        let repository = MockExpenseRepository()
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { currentDate }
        )

        await viewModel.refresh(for: makeDate(year: 2025, month: 1, day: 1))

        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 7, day: 1))
        #expect(!viewModel.canSelectPreviousMonth)
        #expect(!viewModel.canSelectNextMonth)
    }

    /// 驗證未來資料會把可選上限延伸至最晚資料月份，且本月仍是下限。
    @MainActor
    @Test func homeViewModelExtendsUpperBoundAfterSavingFutureExpense() async throws {
        let currentDate = makeDate(year: 2026, month: 7, day: 23)
        let futureDate = makeDate(year: 2027, month: 2, day: 5)
        let repository = MockExpenseRepository()
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { currentDate }
        )

        try await repository.addExpense(
            makeExpense(amount: -120, date: futureDate)
        )
        await viewModel.selectMonth(futureDate)

        #expect(viewModel.displayedMonth == makeDate(year: 2027, month: 2, day: 1))
        #expect(viewModel.earliestSelectableMonth == makeDate(year: 2026, month: 7, day: 1))
        #expect(viewModel.latestSelectableMonth == makeDate(year: 2027, month: 2, day: 1))
        #expect(viewModel.canSelectPreviousMonth)
        #expect(!viewModel.canSelectNextMonth)
        #expect(viewModel.monthlyExpense == -120)
    }

    /// 驗證歷史與未來資料會共同形成包含本月的完整可選範圍。
    @MainActor
    @Test func homeViewModelUsesEarliestAndLatestExpenseMonthsAsBounds() async {
        let currentDate = makeDate(year: 2026, month: 7, day: 23)
        let historicalDate = makeDate(year: 2025, month: 11, day: 5)
        let futureDate = makeDate(year: 2027, month: 2, day: 5)
        let repository = MockExpenseRepository(expenses: [
            makeExpense(amount: 80, date: historicalDate),
            makeExpense(amount: -120, date: futureDate)
        ])
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { currentDate }
        )

        await viewModel.refresh(for: currentDate)

        #expect(viewModel.earliestSelectableMonth == makeDate(year: 2025, month: 11, day: 1))
        #expect(viewModel.latestSelectableMonth == makeDate(year: 2027, month: 2, day: 1))
        #expect(viewModel.canSelectPreviousMonth)
        #expect(viewModel.canSelectNextMonth)

        await viewModel.selectMonth(makeDate(year: 2026, month: 10, day: 1))
        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 10, day: 1))
        #expect(viewModel.loadState == .empty)
    }

    /// 驗證較慢的舊月份請求不會覆蓋較新的選擇。
    @MainActor
    @Test func homeViewModelIgnoresStaleMonthRefreshResults() async {
        let januaryDate = makeDate(year: 2026, month: 1, day: 15)
        let februaryDate = makeDate(year: 2026, month: 2, day: 15)
        let januaryStart = makeDate(year: 2026, month: 1, day: 1)
        let repository = MockExpenseRepository(expenses: [
            makeExpense(amount: 100, date: januaryDate),
            makeExpense(amount: 250, date: februaryDate)
        ])
        repository.fetchDelays[januaryStart] = 100_000_000
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { februaryDate }
        )

        let slowRefresh = Task { await viewModel.refresh(for: januaryDate) }
        try? await Task.sleep(nanoseconds: 10_000_000)
        let fastRefresh = Task { await viewModel.refresh(for: februaryDate) }
        await slowRefresh.value
        await fastRefresh.value

        #expect(viewModel.displayedMonth == makeDate(year: 2026, month: 2, day: 1))
        #expect(viewModel.monthlyIncome == 250)
        #expect(viewModel.expenses.first?.amount == 250)
    }

    /// 驗證月份刷新失敗時不會保留前一月份內容。
    @MainActor
    @Test func homeViewModelClearsPreviousMonthContentOnRefreshFailure() async {
        let currentDate = makeDate(year: 2026, month: 2, day: 15)
        let repository = MockExpenseRepository(expenses: [
            makeExpense(amount: 100, date: currentDate)
        ])
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { currentDate }
        )

        await viewModel.refresh(for: currentDate)
        #expect(viewModel.loadState == .content)

        repository.shouldFail = true
        await viewModel.refresh(for: currentDate)

        #expect(viewModel.loadState == .failed)
        #expect(viewModel.expenses.isEmpty)
        #expect(viewModel.monthlyBalance == 0)
    }

    /// 驗證新增更早日期資料後，可直接切換並擴張最早月份。
    @MainActor
    @Test func homeViewModelSelectsSavedHistoricalMonthAndUpdatesLowerBound() async throws {
        let currentDate = makeDate(year: 2026, month: 7, day: 23)
        let historicalDate = makeDate(year: 2025, month: 11, day: 5)
        let repository = MockExpenseRepository()
        let useCase = HomeUseCase(repository: repository, calendar: calendar)
        let viewModel = HomeViewModel(
            useCase: useCase,
            now: { currentDate }
        )

        try await repository.addExpense(
            makeExpense(amount: -80, date: historicalDate)
        )
        await viewModel.selectMonth(historicalDate)

        #expect(viewModel.displayedMonth == makeDate(year: 2025, month: 11, day: 1))
        #expect(viewModel.earliestSelectableMonth == makeDate(year: 2025, month: 11, day: 1))
        #expect(viewModel.latestSelectableMonth == makeDate(year: 2026, month: 7, day: 1))
        #expect(viewModel.monthlyExpense == -80)
    }

    /// 驗證新增表單允許儲存未來日期，不額外套用日期上限。
    @MainActor
    @Test func editorAllowsFutureExpenseDate() async {
        let repository = MockExpenseRepository()
        let futureDate = makeDate(year: 2030, month: 12, day: 15)
        let viewModel = ExpenseEditorViewModel(repository: repository)
        viewModel.amountText = "500"
        viewModel.remark = "預先登記"
        viewModel.date = futureDate

        let succeeded = await viewModel.createExpense()

        #expect(succeeded)
        #expect(repository.expenses.first?.date == futureDate)
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
