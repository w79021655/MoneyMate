//
//  CustomTabBarView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/19.
//

import SwiftUI
import SwiftData

struct TabBarView: View {
    enum Tab: Int {
        case home, grid, search

        var accessibilityLabel: LocalizedStringResource {
            switch self {
            case .home: "首頁"
            case .grid: "分類"
            case .search: "搜尋"
            }
        }
    }
    @Environment(AppDependencies.self) private var dependencies
    @State private var selected: Tab = .home
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                switch selected {
                case .home:
                    HomeView(
                        viewModel: dependencies.homeViewModel,
                        onAddExpense: { isShowingAddSheet = true }
                    )
                case .grid:
                    Color.white // TODO: Replace with your real Grid view
                case .search:
                    Color.white // TODO: Replace with your real Search view
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    tabButton(.home, systemName: "house")
                    tabButton(.grid, systemName: "square.grid.2x2")
                    tabButton(.search, systemName: "magnifyingglass")

                    Spacer()

                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus.app")
                    }
                    .accessibilityLabel("新增記帳")
                    .sheet(isPresented: $isShowingAddSheet) {
                        ExpenseEditorSheet(
                            viewModel: dependencies.makeExpenseEditorViewModel(),
                            onSave: {
                                await dependencies.homeViewModel.refresh(for: Date())
                            }
                        )
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                            .presentationCornerRadius(16)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab, systemName: String) -> some View {
        let isSelected = (selected == tab)

        Button {
            selected = tab
        } label: {
            Image(systemName: systemName)
                .symbolVariant(isSelected ? .fill : .none)
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.tint.opacity(isSelected ? 0.18 : 0))
                )
        }
        .tint(isSelected ? Color.accentColor : Color.secondary)
        .animation(.snappy, value: isSelected)
        .accessibilityLabel(tab.accessibilityLabel)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Expense.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    TabBarView()
        .environment(
            AppDependencies(modelContext: container.mainContext)
        )
        .modelContainer(container)
}
