//
//  ExpenseRepository.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation
import SwiftData

final class ExpenseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addExpense(_ expense: Expense) {
        dataProviderHelper.insert(expense, into: context)
    }

    func fetchExpenses(from startDate: Date) -> [Expense] {
        dataProviderHelper.fetchThisMonth(from: context, startDate: startDate)
    }
}
