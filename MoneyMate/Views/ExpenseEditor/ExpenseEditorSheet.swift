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
    @State private var showCategorySheet = false

    var body: some View {
        VStack {
            ExpenseEditorHeaderView(
                amount: $viewModel.amount,
                selectedCategory: $viewModel.category
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showCategorySheet = true
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

            Form {
                Section(header: Text("")) {
                    TextField("輸入金額", text: $viewModel.amountText)
                        .keyboardType(.numberPad)
                }

                DatePicker(selection: $viewModel.date,
                           displayedComponents: [.date, .hourAndMinute]) {
                    Label {
                        Text("日期")
                            .font(Font.bodyMedium)
                            .foregroundStyle(Color.Text.primary)
                    } icon: {
                        Image(systemName: "calendar.badge.plus")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color.Brand.primary)
                    }
                }

                .environment(\.locale, Locale(identifier: "zh_TW"))
                HStack(spacing: 15) {
                    Image(systemName: "dollarsign.bank.building")
                        .foregroundColor(Color.Brand.primary)
                    Text("類型")
                        .font(Font.bodyMedium)
                        .foregroundStyle(Color.Text.primary)
                    Spacer()
                    Picker("選擇類型", selection: $viewModel.type) {
                        Text("支出")
                            .tag(TransactionType.expenditure)
                            .font(Font.bodyMedium)
                        Text("收入")
                            .tag(TransactionType.income)
                            .font(Font.bodyMedium)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }

                HStack(spacing: 15) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color.Brand.primary)
                    Text("備註")
                        .font(Font.bodyMedium)
                        .foregroundStyle(Color.Text.primary)
                    TextField("", text: $viewModel.remark)
                        .font(Font.bodyMedium)
                }
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            CategoryEditorSheet(selectedCategory: $viewModel.category,
                                title: "支出")
                .presentationDetents([.medium])
                .presentationCornerRadius(16)
        }
    }
}

/// 編輯費用標題區塊
struct ExpenseEditorHeaderView: View {
    @Binding var amount: Int
    @Binding var selectedCategory: Category

    var body: some View {
        VStack(alignment: .leading,
               spacing: Spacing.spacing16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(selectedCategory.color)
                        .frame(width: 50, height: 50)
                    Image(systemName: selectedCategory.systemImageName)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                Text(selectedCategory.rawValue)
                    .font(Font.titleLarge)
                    .foregroundStyle(Color.Text.inverse)
                Spacer()
                Text(amount.string)
                    .font(Font.titleLarge)
                    .foregroundStyle(Color.Text.inverse)
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
    }
}

//#Preview {
//    ExpenseEditorSheet()
//}
