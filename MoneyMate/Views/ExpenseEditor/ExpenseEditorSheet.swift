//
//  ExpenseEditorSheet.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/11/6.
//

import SwiftUI
import SwiftData

/// 顯示新增記帳表單，並在儲存成功後通知呼叫端刷新資料。
struct ExpenseEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExpenseEditorViewModel
    @State private var showCategorySheet = false
    private let onSave: @MainActor () async -> Void

    /// 建立使用指定草稿狀態的新增記帳表單。
    /// - Parameters:
    ///   - viewModel: 此次編輯流程專用的表單 ViewModel。
    ///   - onSave: Repository 儲存成功後、關閉 sheet 前執行的非同步操作。
    init(
        viewModel: ExpenseEditorViewModel,
        onSave: @escaping @MainActor () async -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showCategorySheet = true
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                ExpenseEditorHeaderView(
                    amount: $viewModel.amount,
                    selectedCategory: $viewModel.category
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("選擇分類，目前為\(viewModel.category.rawValue)")

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

            Button {
                Task {
                    if await viewModel.createExpense() {
                        await onSave()
                        dismiss()
                    }
                }
            } label: {
                ZStack {
                    Text("儲存")
                        .opacity(viewModel.isSaving ? 0 : 1)

                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                            .accessibilityLabel("儲存中")
                    }
                }
                .font(.titleLarge)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.Brand.primary)
                )
                .shadow(color: Color.Text.primary.opacity(0.15), radius: 16, x: 0, y: 1)
            }
            .padding(.horizontal, 15)
            .disabled(!viewModel.canSubmit || viewModel.isSaving)
            .opacity(viewModel.canSubmit && !viewModel.isSaving ? 1 : 0.5)
        }
        .sheet(isPresented: $showCategorySheet) {
            CategoryEditorSheet(selectedCategory: $viewModel.category,
                                title: "支出")
                .presentationDetents([.medium])
                .presentationCornerRadius(16)
        }
        .alert("無法儲存", isPresented: $viewModel.isShowingSaveError) {
            Button("好", role: .cancel) {}
        } message: {
            Text("資料尚未儲存，請稍後再試。")
        }
    }
}

/// 顯示目前分類與尚未套用收支正負號的輸入金額。
struct ExpenseEditorHeaderView: View {
    @Binding var amount: Int?
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
                Text(amount?.string ?? "0")
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

#Preview {
    let container = try! ModelContainer(
        for: Expense.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let repository = ExpenseRepository(context: container.mainContext)

    ExpenseEditorSheet(
        viewModel: ExpenseEditorViewModel(repository: repository)
    )
    .modelContainer(container)
}
