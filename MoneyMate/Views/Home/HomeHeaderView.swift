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
    let detailText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VerticalSpacer(height: 40)
            Text(dateTitle)
                .font(.caption)
            Text(balance)
                .font(.largeTitle).bold()
            Text(detailText)
                .font(.subheadline)
        }
        .padding(EdgeInsets(
            top: 15,
            leading: 12,
            bottom: 15,
            trailing: 0
        ))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue)
        .clipShape(
            RoundedCorner(
                radius: 12,
                corners: [
                    .bottomLeft,
                    .bottomRight
                ]
            )
        )
        .foregroundColor(.white)
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

//#Preview {
//    HomeHeaderView(
//        dateTitle: "2025-05 結餘",
//        balance: "-700",
//        detailText: "支出：-700    收入：0"
//    )
//}
