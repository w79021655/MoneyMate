//
//  HomeViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import Observation
import SwiftData

/// 描述首頁首次載入與主要內容的互斥狀態。
enum HomeLoadState: Equatable {
    case idle
    case loading
    case content
    case empty
    case failed
}

/// 管理首頁月份統計、交易列表、分頁與錯誤顯示狀態。
@MainActor
@Observable
final class HomeViewModel {
    /// 提供首頁業務操作的 UseCase。
    private let useCase: HomeUseCase

    /// 每次分頁查詢最多載入的資料筆數。
    private let pageSize: Int

    /// 提供目前時間，讓永遠包含在選擇範圍內的本月可在測試中固定。
    private let now: () -> Date

    /// 下一頁查詢使用的穩定複合 cursor。
    private var nextCursor: ExpensePageCursor?

    /// Repository 是否仍有尚未載入的資料。
    private var hasNextPage = false

    /// 用來阻止較舊的 refresh 結果覆蓋較新的畫面狀態。
    private var refreshGeneration = 0

    /// 建立首頁狀態管理器。
    /// - Parameters:
    ///   - useCase: 首頁統計與資料操作流程。
    ///   - pageSize: 單頁最多載入筆數，預設為 20。
    init(
        useCase: HomeUseCase,
        pageSize: Int = 20,
        now: @escaping () -> Date = Date.init
    ) {
        self.useCase = useCase
        self.pageSize = pageSize
        self.now = now

        let currentDate = now()
        let currentMonth = (try? useCase.startOfMonth(containing: currentDate)) ?? currentDate
        self.displayedMonth = currentMonth
        self.earliestSelectableMonth = currentMonth
        self.latestSelectableMonth = currentMonth
    }

    /// 目前畫面統計與查詢所對應的月份基準日期。
    private(set) var displayedMonth: Date

    /// 月份選擇器允許的最早月份。
    private(set) var earliestSelectableMonth: Date

    /// 月份選擇器允許的最晚月份，取本月與最晚記帳月份的較晚者。
    private(set) var latestSelectableMonth: Date

    /// 是否能切換到上一個月份。
    var canSelectPreviousMonth: Bool {
        displayedMonth > earliestSelectableMonth
    }

    /// 是否能切換到下一個月份。
    var canSelectNextMonth: Bool {
        displayedMonth < latestSelectableMonth
    }

    /// 當月收入合計。
    private(set) var monthlyIncome = 0

    /// 當月支出合計，維持負值 convention。
    private(set) var monthlyExpense = 0

    /// 當月收入與支出的代數和。
    private(set) var monthlyBalance = 0

    /// 目前已載入並依 repository 順序排列的記帳資料。
    private(set) var expenses: [Expense] = []

    /// 首頁首次載入與主要內容狀態。
    private(set) var loadState: HomeLoadState = .idle

    /// 是否正在取得下一頁資料。
    private(set) var isLoadingNextPage = false

    /// 上一次分頁請求是否失敗，可由使用者重試。
    private(set) var hasPaginationError = false

    /// 控制已有內容時的一般操作錯誤提示。
    var isShowingOperationError = false

    /// 重新載入指定月份的完整統計與第一頁資料。
    ///
    /// 使用 generation token 與 cancellation 檢查，避免舊請求覆蓋較新的 refresh 結果。
    ///
    /// - Parameter date: 用來決定顯示月份的基準日期。
    func refresh(for date: Date) async {
        refreshGeneration += 1
        let generation = refreshGeneration

        do {
            let currentMonth = try useCase.startOfMonth(containing: now())
            let requestedMonth = try useCase.startOfMonth(containing: date)

            displayedMonth = requestedMonth
            earliestSelectableMonth = min(earliestSelectableMonth, currentMonth)
            latestSelectableMonth = max(latestSelectableMonth, currentMonth)
        } catch {
            resetMonthlyContent()
            loadState = .failed
            return
        }

        resetMonthlyContent()
        loadState = .loading
        isShowingOperationError = false

        do {
            let earliestMonth = try await useCase.fetchEarliestExpenseMonth()
            let latestMonth = try await useCase.fetchLatestExpenseMonth()
            try Task.checkCancellation()
            guard generation == refreshGeneration else { return }

            let currentMonth = try useCase.startOfMonth(containing: now())
            earliestSelectableMonth = min(
                earliestMonth ?? currentMonth,
                currentMonth
            )
            latestSelectableMonth = max(
                latestMonth ?? currentMonth,
                currentMonth
            )
            displayedMonth = min(
                max(displayedMonth, earliestSelectableMonth),
                latestSelectableMonth
            )

            let summary = try await useCase.fetchMonthlySummary(for: displayedMonth)
            try Task.checkCancellation()
            let page = try await useCase.fetchMonthlyExpensePage(
                for: displayedMonth,
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

    /// 切換並載入上一個可選月份。
    func selectPreviousMonth() async {
        guard canSelectPreviousMonth,
              let previousMonth = try? useCase.month(
                byAdding: -1,
                to: displayedMonth
              ) else {
            return
        }

        await refresh(for: previousMonth)
    }

    /// 切換並載入下一個可選月份。
    func selectNextMonth() async {
        guard canSelectNextMonth,
              let nextMonth = try? useCase.month(
                byAdding: 1,
                to: displayedMonth
              ) else {
            return
        }

        await refresh(for: nextMonth)
    }

    /// 切換並載入月份選擇器指定的月份。
    /// - Parameter date: 使用者選擇月份內的任意日期。
    func selectMonth(_ date: Date) async {
        await refresh(for: date)
    }

    /// 當指定記帳是目前列表最後一筆時，視需要載入下一頁。
    /// - Parameter currentExpenseID: 觸發 row 的穩定 UUID。
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

    /// 從目前列表最後一筆重新嘗試載入下一頁。
    func retryNextPage() async {
        guard let lastID = expenses.last?.id else { return }
        await loadNextPageIfNeeded(currentExpenseID: lastID)
    }

    /// 刪除指定記帳，成功後重新載入目前月份。
    /// - Parameter expense: 要刪除的 SwiftData model。
    func delete(_ expense: Expense) async {
        do {
            try await useCase.deleteExpense(expense.persistentModelID)
            await refresh(for: displayedMonth)
        } catch {
            loadState = expenses.isEmpty ? .failed : .content
            isShowingOperationError = !expenses.isEmpty
        }
    }

    /// 清除上一月份的內容與分頁狀態，避免標題和舊資料不一致。
    private func resetMonthlyContent() {
        monthlyIncome = 0
        monthlyExpense = 0
        monthlyBalance = 0
        expenses = []
        nextCursor = nil
        hasNextPage = false
        isLoadingNextPage = false
        hasPaginationError = false
    }
}
