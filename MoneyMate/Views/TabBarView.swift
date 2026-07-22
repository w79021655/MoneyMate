//
//  CustomTabBarView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/19.
//

import SwiftUI
import SwiftData

/// 管理 App 主要分頁與新增記帳 sheet 的根畫面。
struct TabBarView: View {
    /// 表示底部工具列可切換的主要頁面。
    enum Tab: Int {
        case home, grid, search

        /// VoiceOver 朗讀分頁按鈕時使用的在地化名稱。
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
                    // TODO: 以正式的分類頁取代目前的空白預留畫面。
                    Color.white
                case .search:
                    // TODO: 以正式的搜尋頁取代目前的空白預留畫面。
                    Color.white
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

    /// 建立具有選取狀態、動畫與 VoiceOver label 的工具列分頁按鈕。
    /// - Parameters:
    ///   - tab: 按鈕代表的目標分頁。
    ///   - systemName: 顯示使用的 SF Symbol 名稱。
    /// - Returns: 點擊後更新 `selected` 的分頁按鈕。
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
