//
//  CategoryEditorSheet.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/11/7.
//

import SwiftUI

/// 顯示 ExpenseEditor feature 的所有記帳分類，並將使用者選擇回寫至呼叫端 binding。
struct CategoryEditorSheet: View {
    @Binding var selectedCategory: Category
    let title: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, Spacing.spacing16)
                .padding(.bottom, Spacing.spacing16)

            List(Category.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                    dismiss()
                } label: {
                    CategoryEditorRowView(
                        category: category,
                        selectedCategory: $selectedCategory
                    )
                    .contentShape(Rectangle())
                }
                .id(category.id)
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .background(Color.Background.card)
    }
}

/// 顯示單一分類的圖示、名稱與目前選取狀態。
struct CategoryEditorRowView: View {
    let category: Category
    @Binding var selectedCategory: Category

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 50, height: 50)
                Image(systemName: category.systemImageName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }

            Text(category.rawValue)
                .font(.titleMedium)
                .foregroundColor(Color.Text.primary)
            Spacer()
            if selectedCategory == category {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.Brand.primary)
            }
        }
        .padding()
        .background(Color.Background.card)
    }
}

#Preview {
    CategoryEditorSheet(selectedCategory: .constant(Category.dining),
                        title: "支出")
}
