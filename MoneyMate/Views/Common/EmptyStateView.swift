//
//  EmptyStateView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/10/23.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 8)

            Text(title)
                .font(.headline)
                .foregroundColor(Color.Text.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(Color.Text.secondary)

            if let action {
                Button(action: action) {
                    Label("新增記帳", systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.Brand.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "目前沒有任何記帳",
        message: "開始新增第一筆收支紀錄吧！",
        systemImage: "doc.text.magnifyingglass"
    ) {
        print("新增記帳被點擊")
    }
}
