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

    @State private var offsetX: CGFloat = 0
    private let deleteWidth: CGFloat = 80

    @State private var isHorizontalDragging: Bool? = nil

    var amountColor: Color {
        expense.type == .expenditure ? .red : .black
    }

    var formattedAmount: String {
        NumberFormatter.currency.string(from: NSNumber(value: expense.amount)) ?? "\(expense.amount)"
    }

    var formattedDate: String {
        DateFormatter.localized.string(from: expense.date)
    }

    var body: some View {
        rowContent
    }

    var rowContent: some View {
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
                Text(formattedDate)
                    .font(Font.bodyMedium)
                    .foregroundColor(Color.Text.secondary)
                Text(expense.remark)
                    .font(.titleMedium)
                    .foregroundColor(Color.Text.primary)
            }

            Spacer()

            Text(formattedAmount)
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
