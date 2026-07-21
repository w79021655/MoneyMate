//
//  HomeHeaderView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import SwiftUI

struct HomeHeaderView: View {
    let month: Date
    let balance: Int
    let income: Int
    let expenditure: Int

    var body: some View {
        VStack(alignment: .leading,
               spacing: Spacing.spacing16) {
            VerticalSpacer(width: 0, height: 40)
            Text("\(month, format: .dateTime.year().month()) 結餘")
                .font(Font.labelSmall)
            Text(balance, format: .number)
                .font(Font.displayLarge)
            IncomeExpenditureView(
                income: income,
                expenditure: expenditure
            )
        }
        .padding(EdgeInsets(
            top: Spacing.spacing16,
            leading: Spacing.spacing12,
            bottom: Spacing.spacing16,
            trailing: 0
        ))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Brand.primary)
        .clipShape(
            RoundedCorner(
                radius: Radius.radius12,
                corners: [
                    .bottomLeft,
                    .bottomRight
                ]
            )
        )
        .foregroundColor(Color.Text.inverse)
    }

}

private struct IncomeExpenditureView: View {
    let income: Int
    let expenditure: Int

    var body: some View {
        HStack {
            Text("收入：\(income, format: .number)")
            VerticalSpacer(width: 15, height: 0)
            Text("支出：\(expenditure, format: .number)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Brand.primary)
        .clipShape(
            RoundedCorner(
                radius: Radius.radius12,
                corners: [
                    .bottomLeft,
                    .bottomRight
                ]
            )
        )
        .foregroundColor(Color.Text.inverse)
        .font(Font.labelLarge)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeHeaderView(
        month: Date(),
        balance: -700,
        income: 0,
        expenditure: -700
    )
}
