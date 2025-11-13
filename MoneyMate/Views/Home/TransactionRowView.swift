//
//  TransactionRowView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import SwiftUI

struct TransactionRowView: View {
    let expense: Expense

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
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.Shadow.card, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    TransactionRowView(expense:
            .init(amount: -700,
                  category: .car,
                  type: .expenditure,
                  date: Date(),
                  dateTime: Date(),
                  remark: "鐵道月卡")
    )
    .padding(15)
}
