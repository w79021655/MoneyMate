//
//  HomeUseCase.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation
import SwiftData

/// 封裝單一月份的收入、支出與衍生餘額。
struct MonthlySummary: Equatable {
    /// 當月所有正值記帳的合計。
    let income: Int

    /// 當月所有負值記帳的合計。
    let expense: Int

    /// 收入與支出的代數和。
    var balance: Int { income + expense }
}

/// 表示首頁業務流程無法建立有效月份區間的錯誤。
enum HomeUseCaseError: Error {
    case invalidMonthInterval
}

/// 協調首頁月份統計、分頁查詢與刪除記帳的業務流程。
@MainActor
final class HomeUseCase {
    /// 提供記帳 persistence 操作的資料介面。
    private let repository: any ExpenseRepositoryProtocol

    /// 決定月份邊界與 time zone 的日曆。
    private let calendar: Calendar

    /// 建立首頁業務流程。
    /// - Parameters:
    ///   - repository: 查詢與刪除記帳的資料介面。
    ///   - calendar: 計算半開月份區間的日曆，預設跟隨系統設定更新。
    init(
        repository: any ExpenseRepositoryProtocol,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.repository = repository
        self.calendar = calendar
    }

    /// 計算指定日期所屬月份的收入、支出與餘額。
    /// - Parameter date: 用來決定目標月份的基準日期。
    /// - Returns: 涵蓋該月所有記帳的統計結果。
    /// - Throws: 月份區間無法建立或 repository 查詢失敗時拋出錯誤。
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

    /// 取得指定月份的一頁記帳資料。
    /// - Parameters:
    ///   - date: 用來決定目標月份的基準日期。
    ///   - cursor: 上一頁最後一筆的位置；`nil` 表示第一頁。
    ///   - limit: 單頁最多回傳筆數。
    /// - Returns: 當頁記帳與下一頁狀態。
    /// - Throws: 月份區間無法建立或 repository 查詢失敗時拋出錯誤。
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

    /// 刪除指定 persistent identifier 的記帳。
    /// - Parameter id: 要刪除的 SwiftData identifier。
    /// - Throws: Repository 無法完成刪除時拋出錯誤。
    func deleteExpense(_ id: PersistentIdentifier) async throws {
        try await repository.deleteByPersistentId(id)
    }

    /// 建立包含指定日期的半開月份區間 `[start, end)`。
    /// - Parameter date: 用來定位月份的基準日期。
    /// - Returns: 由注入 calendar 計算的完整月份區間。
    /// - Throws: Calendar 無法建立月份區間時拋出 `HomeUseCaseError.invalidMonthInterval`。
    private func monthInterval(containing date: Date) throws -> DateInterval {
        guard let interval = calendar.dateInterval(of: .month, for: date) else {
            throw HomeUseCaseError.invalidMonthInterval
        }

        return interval
    }
}
