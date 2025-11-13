//
//  ContentView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/2.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        VStack {
            HomeHeaderView(
                dateTitle: homeViewModel.currentMonthTitle,
                balance: "\(homeViewModel.monthlyBalance)",
                income: homeViewModel.incomeText,
                expenditure: homeViewModel.expenditureText
            )

            TrackableScrollView {
                LazyVStack {
                    if homeViewModel.expenses.isEmpty {
                        EmptyStateView(
                            title: "目前沒有任何記帳",
                            message: "開始新增第一筆收支紀錄吧！",
                            systemImage: "doc.text.magnifyingglass"
                        ) {
                            print("新增記帳被點擊")
                        }
                        .padding(.top, 200)
                    } else {
                        ForEach(homeViewModel.expenses) { expense in
                            TransactionRowView(expense: expense)
                            .padding(.horizontal, 15)
                            .padding(.top, expense == homeViewModel.expenses.first ? 16 : 12)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .task {
                                if expense == homeViewModel.expenses.last {
                                    await homeViewModel.loadNextPageIfNeeded()
                                }
                            }
                        }
                        .background(Color.Background.screen)
                        loadingRow
                    }
                }
                .task {
//                    await homeViewModel.addTestData()
                    await homeViewModel.fetchMonthlySummary(for: Date())
                    await homeViewModel.fetchMonthlyExpense(for: Date())
                }
            }
        }
        .background(Color.Background.screen)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            modelContextProvider.configure(context: context)
        }
    }

    @ViewBuilder
    var loadingRow: some View {
        if homeViewModel.isLoadingNextPage {
            HStack {
                Spacer()
                ProgressView()
                    .id(homeViewModel.progressID)
                    .tint(Color.Border.loading)
                    .scaleEffect(1.2)
                    .padding(.vertical, 20)
                Spacer()
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    // 1) 讀取 ScrollView 偏移量的 PreferenceKey
    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    // 2) 可追蹤偏移量的 ScrollView（上報 y 偏移）
    struct TrackableScrollView<Content: View>: View {
        let content: Content
        init(@ViewBuilder content: () -> Content) { self.content = content() }

        var body: some View {
            ScrollView {
                // 這個錨點用來計算 content 相對於全域座標的 y
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                }
                .frame(height: 0)
                content
            }
        }
    }
}

#Preview {
    HomeView()
}
