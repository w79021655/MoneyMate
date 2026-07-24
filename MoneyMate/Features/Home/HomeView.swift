//
//  ContentView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/2.
//

import SwiftUI

/// 組合 Home feature 的摘要與內容區，並負責啟動首次月份載入。
struct HomeView: View {
    private let viewModel: HomeViewModel
    private let onAddExpense: EmptyClosure

    /// 建立使用指定首頁狀態與新增記帳操作的畫面。
    /// - Parameters:
    ///   - viewModel: 首頁統計、列表與錯誤狀態的 source of truth。
    ///   - onAddExpense: 使用者從空狀態要求新增記帳時執行的操作。
    init(
        viewModel: HomeViewModel,
        onAddExpense: @escaping EmptyClosure
    ) {
        self.viewModel = viewModel
        self.onAddExpense = onAddExpense
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack {
            HomeHeaderView(
                month: viewModel.displayedMonth,
                earliestSelectableMonth: viewModel.earliestSelectableMonth,
                latestSelectableMonth: viewModel.latestSelectableMonth,
                canSelectPreviousMonth: viewModel.canSelectPreviousMonth,
                canSelectNextMonth: viewModel.canSelectNextMonth,
                balance: viewModel.monthlyBalance,
                income: viewModel.monthlyIncome,
                expenditure: viewModel.monthlyExpense,
                onPreviousMonth: {
                    Task {
                        await viewModel.selectPreviousMonth()
                    }
                },
                onNextMonth: {
                    Task {
                        await viewModel.selectNextMonth()
                    }
                },
                onSelectMonth: { month in
                    Task {
                        await viewModel.selectMonth(month)
                    }
                }
            )

            HomeContentView(
                viewModel: viewModel,
                onAddExpense: onAddExpense
            )
        }
        .background(Color.Background.screen)
        .ignoresSafeArea(.container, edges: .top)
        .task {
            await viewModel.refresh(for: Date())
        }
        .alert("作業失敗", isPresented: $viewModel.isShowingOperationError) {
            Button("好", role: .cancel) {}
        } message: {
            Text("資料未能更新，請稍後再試。")
        }
    }
}

/// 依首頁載入狀態切換載入、空資料、錯誤或交易列表內容。
private struct HomeContentView: View {
    let viewModel: HomeViewModel
    let onAddExpense: EmptyClosure

    var body: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            ProgressView("載入中")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            EmptyStateView(
                title: "這個月份沒有記帳",
                message: "可以新增一筆收支紀錄。",
                systemImage: "doc.text.magnifyingglass",
                action: onAddExpense
            )

        case .failed:
            HomeLoadErrorView {
                Task {
                    await viewModel.refresh(for: viewModel.displayedMonth)
                }
            }

        case .content:
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.expenses) { expense in
                        TransactionRowView(
                            expense: expense,
                            onDelete: {
                                Task {
                                    await viewModel.delete(expense)
                                }
                            }
                        )
                        .padding(.horizontal, Spacing.spacing16)
                        .padding(.top, expense.id == viewModel.expenses.first?.id ? Spacing.spacing16 : Spacing.spacing12)
                        .task {
                            await viewModel.loadNextPageIfNeeded(
                                currentExpenseID: expense.id
                            )
                        }
                    }

                    PaginationStatusView(
                        isLoading: viewModel.isLoadingNextPage,
                        hasError: viewModel.hasPaginationError,
                        onRetry: {
                            Task {
                                await viewModel.retryNextPage()
                            }
                        }
                    )
                }
            }
        }
    }
}

/// 顯示下一頁載入進度或分頁重試操作。
private struct PaginationStatusView: View {
    let isLoading: Bool
    let hasError: Bool
    let onRetry: EmptyClosure

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .tint(Color.Border.loading)
                    .scaleEffect(1.2)
                    .accessibilityLabel("正在載入更多記帳")
            } else if hasError {
                Button("重新載入更多記帳", action: onRetry)
            }
        }
        .padding(.vertical, Spacing.spacing16)
    }
}

/// 顯示首頁首次載入失敗狀態與重試操作。
private struct HomeLoadErrorView: View {
    let onRetry: EmptyClosure

    var body: some View {
        VStack(spacing: Spacing.spacing16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(Color.Text.secondary)
                .accessibilityHidden(true)

            Text("無法載入記帳資料")
                .font(.headline)

            Text("請確認後再試一次。")
                .font(.subheadline)
                .foregroundStyle(Color.Text.secondary)

            Button("重新載入", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.spacing16)
    }
}
