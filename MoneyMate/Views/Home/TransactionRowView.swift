//
//  TransactionRowView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import SwiftUI

struct TransactionRowView: View {
    let expense: Expense
    let onDelete: EmptyClosure

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
                Text(expense.date, format: .dateTime.year().month().day())
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
