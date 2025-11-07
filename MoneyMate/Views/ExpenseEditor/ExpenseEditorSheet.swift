//
//  ExpenseEditorSheet.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/11/6.
//

import SwiftUI

/// 編輯費用畫面
struct ExpenseEditorSheet: View {
    @StateObject var viewModel = ExpenseEditorViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            ExpenseEditorHeaderView(
                categoryTitle: "餐飲支出",
                amountText: "1200",
                icon: Category.dining.systemImageName,
                iconColor: .red
            )

            Form {
                Section(header: Text("")) {
                    TextField("輸入金額", text: $viewModel.amountText)
                        .keyboardType(.numberPad)
                }

                DatePicker(selection: $viewModel.date,
                           displayedComponents: [.date, .hourAndMinute]) {
                    Label {
                        Text("日期")
                            .font(Font.bodyLarge)
                            .foregroundStyle(Color.Text.primary)
                    } icon: {
                        Image(systemName: "calendar.badge.plus")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color.Brand.primary)
                    }
                }
                           .environment(\.locale, Locale(identifier: "zh_TW"))

                HStack(spacing: 15) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color.Brand.primary)
                    Text("備註")
                        .font(Font.bodyLarge)
                        .foregroundStyle(Color.Text.primary)
                    TextField("", text: $viewModel.remark)
                        .font(Font.bodyLarge)
                }
            }
        }
    }
}

struct ExpenseEditorHeaderView: View {
    let categoryTitle: String
    let amountText: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading,
               spacing: Spacing.spacing16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                Text(categoryTitle)
                    .font(Font.titleLarge)
                Spacer()
                Text(amountText)
                    .font(Font.titleLarge)
            }
        }
        .padding(EdgeInsets(
            top: Spacing.spacing16,
            leading: Spacing.spacing16,
            bottom: Spacing.spacing16,
            trailing: Spacing.spacing16
        ))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Brand.primary)
        .foregroundColor(Color.Text.inverse)
    }
}

#Preview {
    ExpenseEditorSheet()
}
