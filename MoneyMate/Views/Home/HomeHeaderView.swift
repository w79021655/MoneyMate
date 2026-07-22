//
//  HomeHeaderView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import SwiftUI

/// 顯示目前月份的餘額、收入與支出摘要。
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

/// 顯示首頁摘要中的收入與支出合計。
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

/// 只對指定角落套用圓角的自訂 Shape。
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    /// 建立符合指定半徑與角落集合的路徑。
    /// - Parameter rect: SwiftUI 提供的繪製範圍。
    /// - Returns: 由 `UIBezierPath` 轉換的 SwiftUI `Path`。
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
