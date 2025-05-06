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
        ["支出：",
         monthlyExpense.string,
         "收入：",
         monthlyIncome.string].joinedString()
    }

    var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "\(formatter.string(from: Date())) 結餘"
    }

    func configureIfNeeded(context: ModelContext) {
//        var expenseEditorViewModel = ExpenseEditorViewModel()
//        expenseEditorViewModel.configureIfNeeded(context: context)
//        expenseEditorViewModel.insertMockExpenses()

        guard repository == nil else { return }
        repository = ExpenseRepository(context: context)
        fetchMonthlySummary(for: Date())
    }

    func fetchMonthlySummary(for date: Date) {
        guard let expenses = repository?.fetchExpenses(from: date) else { return }

        let income = expenses.filter { $0.amount > 0 }.map(\.amount).reduce(0, +)
        let expense = expenses.filter { $0.amount < 0 }.map(\.amount).reduce(0, +)

        monthlyIncome = income
        monthlyExpense = expense
        monthlyBalance = income + expense
    }
}
