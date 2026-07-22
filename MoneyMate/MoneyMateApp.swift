//
//  MoneyMateApp.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/2.
//

import SwiftUI
import SwiftData

/// 建立 SwiftData 容器與 App dependency graph 的應用程式入口。
@main
struct MoneyMateApp: App {
    /// App 生命週期內持有的 production SwiftData 容器。
    private let modelContainer: ModelContainer

    /// 由主 `ModelContext` 建立並注入 View tree 的共用依賴。
    private let dependencies: AppDependencies

    /// 建立 production persistence stack；容器無法建立時終止啟動。
    @MainActor
    init() {
        do {
            let modelContainer = try ModelContainer(for: Expense.self)
            self.modelContainer = modelContainer
            self.dependencies = AppDependencies(
                modelContext: modelContainer.mainContext
            )
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(dependencies)
        }
        .modelContainer(modelContainer)
    }
}
