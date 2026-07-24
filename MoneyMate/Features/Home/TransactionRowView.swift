//
//  TransactionRowView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import SwiftUI

/// 顯示 Home feature 單筆記帳的日期、分類、備註、金額與內容選單操作。
struct TransactionRowView: View {
    let expense: Expense
    let onDelete: EmptyClosure

    /// 依收支類型決定金額的語意色彩。
    var amountColor: Color {
        expense.type == .expenditure ? .red : .black
    }

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(expense.category.color)
                    .frame(width: 50, height: 50)
                Image(systemName: expense.category.systemImageName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: expense.date.formatted(AppDateFormat.yearMonthDay))
                    .font(Font.bodyMedium)
                    .foregroundColor(Color.Text.secondary)
                Text(expense.remark)
                    .font(.titleMedium)
                    .foregroundColor(Color.Text.primary)
            }

            Spacer()

            Text(expense.amount, format: .number)
                .font(Font.titleLarge)
                .foregroundColor(amountColor)
        }
        .padding()
        .background(Color.Background.card)
        .cardStyle()
        .contextMenu {
            Button {

            } label: {
                Label("編輯", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("刪除", systemImage: "trash")
            }
        }
    }
}

#Preview {
    TransactionRowView(
        expense: .init(
            amount: -700,
            category: .car,
            type: .expenditure,
            date: Date(),
            dateTime: Date(),
            remark: "鐵道月卡"
        ),
        onDelete: {
            print("Delete tapped (Preview)")
        }
    )
    .padding(15)
}
