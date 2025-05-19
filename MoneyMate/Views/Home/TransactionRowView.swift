//
//  TransactionRowView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//


import SwiftUI

struct TransactionRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let date: Date
    let amount: Int

    var amountColor: Color {
        amount < 0 ? .red : .black
    }

    var formattedAmount: String {
        NumberFormatter.currency.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    var formattedDate: String {
        DateFormatter.localized.string(from: date)
    }

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(Font.bodyMedium)
                    .foregroundColor(Color.Text.secondary)
                Text(title)
                    .font(.titleMedium)
                    .foregroundColor(Color.Text.primaryDark)
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
    TransactionRowView(
        icon: "train.side.front.car",
        iconColor: .blue,
        title: "鐵道月卡",
        date: Date(),
        amount: -700
    )
    .padding(15)
}
