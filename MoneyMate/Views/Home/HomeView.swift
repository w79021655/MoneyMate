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

            List {
                ForEach(homeViewModel.expenses) { expense in
                    TransactionRowView(
                        icon: expense.category.systemImageName,
                        iconColor: expense.category.color,
                        title: expense.remark,
                        date: expense.date,
                        amount: expense.amount
                    )
                    .padding(.horizontal, 15)
                    .padding(.top, expense == homeViewModel.expenses.first ? 16 : 12)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .onAppear {
                        if expense == homeViewModel.expenses.last {
                            homeViewModel.loadNextPageIfNeeded()
                        }
                    }
                }
                .background(Color.Background.screen)
                loadingRow
            }
            .listStyle(.plain)
            .onAppear {
                homeViewModel.fetchMonthlySummary(for: Date())
                homeViewModel.fetchMonthlyExpense(for: Date())
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
}

#Preview {
    HomeView()
}
