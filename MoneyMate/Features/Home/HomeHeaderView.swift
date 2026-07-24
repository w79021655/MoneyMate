//
//  HomeHeaderView.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import SwiftUI

/// 顯示 Home feature 目前月份的餘額、收入與支出摘要。
struct HomeHeaderView: View {
    @State private var isShowingMonthPicker = false

    let month: Date
    let earliestSelectableMonth: Date
    let latestSelectableMonth: Date
    let canSelectPreviousMonth: Bool
    let canSelectNextMonth: Bool
    let balance: Int
    let income: Int
    let expenditure: Int
    let onPreviousMonth: EmptyClosure
    let onNextMonth: EmptyClosure
    let onSelectMonth: (Date) -> Void

    var body: some View {
        VStack(alignment: .leading,
               spacing: Spacing.spacing16) {
            VerticalSpacer(width: 0, height: 40)

            MonthNavigationView(
                month: month,
                canSelectPreviousMonth: canSelectPreviousMonth,
                canSelectNextMonth: canSelectNextMonth,
                onPreviousMonth: onPreviousMonth,
                onNextMonth: onNextMonth,
                onShowMonthPicker: {
                    isShowingMonthPicker = true
                }
            )

            Text("結餘")
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
        .sheet(isPresented: $isShowingMonthPicker) {
            MonthPickerSheet(
                selectedMonth: month,
                earliestMonth: earliestSelectableMonth,
                latestMonth: latestSelectableMonth,
                onSelectMonth: onSelectMonth
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.Background.screen)
        }
    }

}

/// 提供首頁逐月切換與月份選擇器入口。
private struct MonthNavigationView: View {
    let month: Date
    let canSelectPreviousMonth: Bool
    let canSelectNextMonth: Bool
    let onPreviousMonth: EmptyClosure
    let onNextMonth: EmptyClosure
    let onShowMonthPicker: EmptyClosure

    var body: some View {
        HStack {
            Button(action: onPreviousMonth) {
                Image(systemName: "chevron.left")
                    .frame(width: Spacing.spacing44, height: Spacing.spacing44)
                    .contentShape(Rectangle())
            }
            .disabled(!canSelectPreviousMonth)
            .opacity(canSelectPreviousMonth ? 1 : 0.35)
            .accessibilityLabel("上一個月")

            Spacer()

            Button(action: onShowMonthPicker) {
                HStack(spacing: Spacing.spacing4) {
                    Text(verbatim: month.formatted(AppDateFormat.yearMonth))
                        .font(Font.titleMedium)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .frame(minHeight: Spacing.spacing44)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(
                "選擇月份，目前為\(month.formatted(AppDateFormat.yearMonth))"
            )

            Spacer()

            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .frame(width: Spacing.spacing44, height: Spacing.spacing44)
                    .contentShape(Rectangle())
            }
            .disabled(!canSelectNextMonth)
            .opacity(canSelectNextMonth ? 1 : 0.35)
            .accessibilityLabel("下一個月")
        }
        .buttonStyle(.plain)
    }
}

/// 以年份滾輪與月份網格選擇首頁要顯示的月份。
private struct MonthPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedYear: Int

    let selectedMonth: Date
    let earliestMonth: Date
    let latestMonth: Date
    let onSelectMonth: (Date) -> Void

    private let calendar: Calendar

    init(
        selectedMonth: Date,
        earliestMonth: Date,
        latestMonth: Date,
        calendar: Calendar = .autoupdatingCurrent,
        onSelectMonth: @escaping (Date) -> Void
    ) {
        self.selectedMonth = selectedMonth
        self.earliestMonth = earliestMonth
        self.latestMonth = latestMonth
        self.calendar = calendar
        self.onSelectMonth = onSelectMonth
        _selectedYear = State(
            initialValue: calendar.component(.year, from: selectedMonth)
        )
    }

    var body: some View {
        VStack(spacing: Spacing.spacing12) {
            MonthPickerHeaderView {
                dismiss()
            }

            Picker("年份", selection: $selectedYear) {
                ForEach(availableYears, id: \.self) { year in
                    Text(verbatim: "\(year)年")
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .accessibilityLabel("年份")

            ScrollView {
                LazyVGrid(columns: monthColumns, spacing: Spacing.spacing8) {
                    ForEach(1...12, id: \.self) { month in
                        MonthButton(
                            month: month,
                            isSelected: isSelected(month),
                            isEnabled: isAvailable(month)
                        ) {
                            select(month)
                        }
                    }
                }
                .padding(.bottom, Spacing.spacing16)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, Spacing.spacing16)
        .padding(.top, Spacing.spacing8)
    }

    private var monthColumns: [GridItem] {
        let columnCount = dynamicTypeSize.isAccessibilitySize ? 2 : 3
        return Array(
            repeating: GridItem(.flexible(), spacing: Spacing.spacing8),
            count: columnCount
        )
    }

    private var availableYears: [Int] {
        let firstYear = calendar.component(.year, from: earliestMonth)
        let lastYear = calendar.component(.year, from: latestMonth)
        return Array(firstYear...lastYear)
    }

    private func date(for month: Int) -> Date? {
        calendar.date(
            from: DateComponents(year: selectedYear, month: month, day: 1)
        )
    }

    private func isAvailable(_ month: Int) -> Bool {
        guard let date = date(for: month) else { return false }
        return date >= earliestMonth && date <= latestMonth
    }

    private func isSelected(_ month: Int) -> Bool {
        calendar.component(.year, from: selectedMonth) == selectedYear &&
            calendar.component(.month, from: selectedMonth) == month
    }

    private func select(_ month: Int) {
        guard let date = date(for: month), isAvailable(month) else { return }
        onSelectMonth(date)
        dismiss()
    }
}

/// 顯示月份選擇器標題與明確的關閉操作。
private struct MonthPickerHeaderView: View {
    let onDismiss: EmptyClosure

    var body: some View {
        HStack {
            Text("選擇月份")
                .font(Font.titleMedium)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .frame(
                        width: Spacing.spacing44,
                        height: Spacing.spacing44
                    )
                    .background(
                        Color.Background.card,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("關閉月份選擇器")
        }
        .frame(minHeight: Spacing.spacing44)
    }
}

/// 顯示月份選擇器中的單一月份按鈕。
private struct MonthButton: View {
    let month: Int
    let isSelected: Bool
    let isEnabled: Bool
    let action: EmptyClosure

    var body: some View {
        Button(action: action) {
            Text(verbatim: "\(month)月")
                .font(Font.bodyMedium)
                .frame(maxWidth: .infinity, minHeight: Spacing.spacing44)
                .background(
                    isSelected ? Color.Brand.primary : Color.Background.card,
                    in: RoundedRectangle(cornerRadius: Radius.radius12)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.radius12)
                        .stroke(
                            isSelected ? Color.clear : Color.Border.subtle,
                            lineWidth: 1
                        )
                }
                .foregroundStyle(
                    isSelected
                        ? Color.Text.inverse
                        : isEnabled
                            ? Color.Text.primary
                            : Color.Text.secondary
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel("\(month)月")
        .accessibilityHidden(!isEnabled)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
        earliestSelectableMonth: Date(),
        latestSelectableMonth: Date(),
        canSelectPreviousMonth: true,
        canSelectNextMonth: false,
        balance: -700,
        income: 0,
        expenditure: -700,
        onPreviousMonth: {},
        onNextMonth: {},
        onSelectMonth: { _ in }
    )
}
