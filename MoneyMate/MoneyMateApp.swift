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
    private let modelContainer: ModelContainer
    private let dependencies: AppDependencies

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
