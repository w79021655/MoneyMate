//
//  HomeViewModel.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import SwiftData

final class HomeViewModel: ObservableObject {
    private var useCase = HomeUseCase()

    /// 紀錄該頁是否滿足20筆資料
    private var limitExpenses: [Expense] = []

    /// 每月收入
    @Published var monthlyIncome: Int = 0

    /// 每月支出
    @Published var monthlyExpense: Int = 0

    /// 每月餘額
    @Published var monthlyBalance: Int = 0

    /// 每月收入支出清單
    @Published var expenses: [Expense] = []

    /// 是否顯示加載動畫
    @Published var isLoadingNextPage: Bool = false

    /// 強制刷新 ProgressView 的 ID
    @Published var progressID = UUID()

    var incomeText: String {
        ["收入：", monthlyIncome.string].joinedString()
    }

    var expenditureText: String {
        ["支出：", monthlyExpense.string].joinedString()
    }
    
    var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return "\(formatter.string(from: Date())) 結餘"
    }

    /// 回傳每月統計結果
    func fetchMonthlySummary(for date: Date) {
//        let expenseEditorViewModel = ExpenseEditorViewModel()
//        expenseEditorViewModel.deleteAll()
//        expenseEditorViewModel.insertMockExpenses()

        let result = useCase.fetchMonthlySummary(for: date)
        monthlyIncome = result.income
        monthlyExpense = result.expense
        monthlyBalance = result.balance
    }

    /// 取得指定起始日期往後抓取指定 20 筆數的資料
    func fetchMonthlyExpense(for date: Date) {
        let expenses = useCase.fetchMonthlyExpense(for: date)
        self.expenses = expenses
        limitExpenses = expenses
    }

    /// 載入下一頁
    func loadNextPageIfNeeded() {
        guard !isLoadingNextPage,
              !expenses.isEmpty,
              limitExpenses.count >= 20 else { return }

        progressID = UUID()
        isLoadingNextPage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let lastDate = self.expenses[self.expenses.count - 1].date
            let nextPage = self.useCase.fetchMonthlyExpense(for: lastDate)
            let newItems = nextPage.filter { !self.expenses.contains($0) }
            if !newItems.isEmpty {
                self.expenses.append(contentsOf: newItems)
                self.limitExpenses = newItems
            }
            self.isLoadingNextPage = false
        }
    }
}
