//
//  ExpenseRepositoryProtocol.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation

protocol ExpenseRepositoryProtocol {

    func addExpense(_ expense: Expense) async

    func deleteAll() async

    /// 取得指定起始日期往後抓取指定 20 筆數的資料
    func fetchExpenses(from startDate: Date) async -> [Expense]

    func addTestData() async
}
