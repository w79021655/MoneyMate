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
    let expenseRepository: ExpenseRepository
    let homeViewModel: HomeViewModel

    init(modelContext: ModelContext) {
        let expenseRepository = ExpenseRepository(context: modelContext)

        self.expenseRepository = expenseRepository
        self.homeViewModel = HomeViewModel(
            useCase: HomeUseCase(repository: expenseRepository)
        )
    }

    /// 編輯器每次開啟都需要一份新的草稿狀態。
    func makeExpenseEditorViewModel() -> ExpenseEditorViewModel {
        ExpenseEditorViewModel(repository: expenseRepository)
    }
}
