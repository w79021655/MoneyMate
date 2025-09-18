//
//  MoneyMateApp.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/2.
//

import SwiftUI
import SwiftData

@main
struct MoneyMateApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
        .modelContainer(for: Expense.self) // 註冊資料模型
    }
}
