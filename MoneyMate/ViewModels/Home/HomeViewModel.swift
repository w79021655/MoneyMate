//
//  HomeViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import SwiftData

final class HomeViewModel: ObservableObject {
    private var repository: ExpenseRepository?
    private let calendar = Calendar.current

    /// 每月收入
    @Published var monthlyIncome: Int = 0

    /// 每月支出
    @Published var monthlyExpense: Int = 0

    /// 每月餘額
    @Published var monthlyBalance: Int = 0

    var monthlyDetailText: String {
        ["支出：-",
         monthlyExpense.string,
         "收入：",
         monthlyIncome.string].joinedString()
    }
    
    func configureIfNeeded(context: ModelContext) {
        guard repository == nil else { return }
        repository = ExpenseRepository(context: context)
        fetchMonthlySummary(for: Date())
    }

    func fetchMonthlySummary(for date: Date) {
//        let range = calendar.dateInterval(of: .month, for: date)!
//        guard let expenses = repository?.fetchExpenses(from: range.start, to: range.end) else { return }

//        let income = expenses.filter { $0.amount > 0 }.map(\.amount).reduce(0, +)
//        let expense = expenses.filter { $0.amount < 0 }.map(\.amount).reduce(0, +)

        let income = 70000
        let expense = 700

        monthlyIncome = income
        monthlyExpense = expense
        monthlyBalance = income + expense
    }
}
