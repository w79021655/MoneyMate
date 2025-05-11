//
//  HomeHeaderView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import SwiftUI

struct HomeHeaderView: View {
    let dateTitle: String
    let balance: String
    let income: String
    let expenditure: String

    var body: some View {
        VStack(alignment: .leading,
               spacing: Spacing.spacing16) {
            VerticalSpacer(width: 0, height: 40)
            Text(dateTitle)
                .font(Font.labelSmall)
            Text(balance)
                .font(Font.displayLarge)
            incomeExpenditure
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

    var incomeExpenditure: some View {
        HStack {
            Text(income)
            VerticalSpacer(width: 15, height: 0)
            Text(expenditure)
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
        dateTitle: "2025-05 結餘",
        balance: "-700",
        income: "收入：0",
        expenditure: "支出：-700"
    )
}
