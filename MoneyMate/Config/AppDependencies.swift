//
//  AppDependencies.swift
//  MoneyMate
//

import Observation
import SwiftData

/// App composition root，集中建立並配送 production dependencies。
@MainActor
@Observable
final class AppDependencies {
    /// App 生命週期內共用的支出資料存取介面。
    let expenseRepository: ExpenseRepository

    /// 首頁共用的畫面狀態與使用者操作入口。
    let homeViewModel: HomeViewModel

    /// 使用指定的 SwiftData context 建立 production dependency graph。
    /// - Parameter modelContext: App 主容器所提供的 `ModelContext`。
    init(modelContext: ModelContext) {
        let expenseRepository = ExpenseRepository(context: modelContext)

        self.expenseRepository = expenseRepository
        self.homeViewModel = HomeViewModel(
            useCase: HomeUseCase(repository: expenseRepository)
        )
    }

    /// 建立一份不與其他編輯流程共用草稿狀態的 ViewModel。
    /// - Returns: 使用 App 共用 repository 的全新 `ExpenseEditorViewModel`。
    func makeExpenseEditorViewModel() -> ExpenseEditorViewModel {
        ExpenseEditorViewModel(repository: expenseRepository)
    }
}
