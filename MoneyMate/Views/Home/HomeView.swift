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
        ScrollView {
            VStack(spacing: 0) {
                HomeHeaderView(
                    dateTitle: homeViewModel.currentMonthTitle,
                    balance: "\(homeViewModel.monthlyBalance)",
                    income: homeViewModel.incomeText,
                    expenditure: homeViewModel.expenditureText
                )
                .background(Color.Background.screen)
                ForEach(0..<50) { i in
                    Text("支出項目 \(i)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.Background.card)
                        .foregroundColor(Color.Text.negative)
                        .border(Color.Brand.subtleRGB)
                }
            }
        }
        .background(Color.Background.screen)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            homeViewModel.configureIfNeeded(context: context)
        }
    }
}

#Preview {
    HomeView()
}
