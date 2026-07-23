#if DEBUG
import Foundation
import SwiftData

/// 建立可供 Preview、模擬器與 UI Test 顯示的虛構記帳資料。
///
/// 資料只會編譯進 Debug build，並應搭配獨立的 in-memory `ModelContainer` 使用。
@MainActor
enum MockExpenseData {
    static let expenseCount = 45

    /// 產生指定日期所在月份的固定筆數記帳資料。
    /// - Parameters:
    ///   - referenceDate: 決定假資料所屬月份的日期。
    ///   - calendar: 建立月份內日期時使用的日曆。
    /// - Returns: 具有穩定 UUID、正確金額正負號與虛構備註的 45 筆資料。
    static func makeExpenses(
        referenceDate: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Expense] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: referenceDate),
              let dayRange = calendar.range(of: .day, in: .month, for: referenceDate) else {
            return []
        }

        let expenseCategories: [Category] = [
            .dining, .transport, .shopping, .home, .entertainment,
            .health, .education, .pets, .utilities, .fitness
        ]
        let expenseRemarks = [
            "午餐", "捷運加值", "日用品", "房屋用品", "電影票",
            "健康檢查", "線上課程", "寵物用品", "水電帳單", "運動用品"
        ]
        let expenseAmounts = [120, 450, 89, 1_280, 320, 650, 999, 760, 1_540, 2_100]
        let incomeRemarks = ["本月薪資", "專案獎金", "股息收入"]
        let incomeAmounts = [52_000, 6_800, 1_250]

        return (0..<expenseCount).compactMap { index in
            let day = dayRange.lowerBound + (index % dayRange.count)
            let hour = 8 + (index * 3 % 14)
            let minute = index * 7 % 60
            guard let dayDate = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthInterval.start
            ),
            let date = calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: dayDate
            ),
            let id = UUID(uuidString: String(format: "00000000-0000-4000-8000-%012d", index + 1)) else {
                return nil
            }

            let isIncome = index.isMultiple(of: 8)
            if isIncome {
                let incomeIndex = (index / 8) % incomeAmounts.count
                return Expense(
                    id: id,
                    amount: incomeAmounts[incomeIndex],
                    category: incomeIndex == 0 ? .salary : .dividend,
                    type: .income,
                    date: date,
                    dateTime: date,
                    remark: incomeRemarks[incomeIndex]
                )
            }

            let expenseIndex = index % expenseAmounts.count
            return Expense(
                id: id,
                amount: -expenseAmounts[expenseIndex],
                category: expenseCategories[expenseIndex],
                type: .expenditure,
                date: date,
                dateTime: date,
                remark: expenseRemarks[expenseIndex]
            )
        }
    }

    /// 建立已載入畫面假資料的獨立 in-memory container。
    /// - Parameter referenceDate: 決定假資料所屬月份的日期。
    /// - Returns: 已儲存 45 筆假資料且不會寫入正式 store 的 container。
    /// - Throws: Container 建立或假資料儲存失敗時拋出錯誤。
    static func makeModelContainer(
        referenceDate: Date = Date()
    ) throws -> ModelContainer {
        let container = try ModelContainer(
            for: Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        try seed(into: container.mainContext, referenceDate: referenceDate)
        return container
    }

    /// 將假資料寫入呼叫端提供的獨立 `ModelContext`。
    /// - Parameters:
    ///   - context: 僅供 Debug 或 Preview 使用的 in-memory context。
    ///   - referenceDate: 決定假資料所屬月份的日期。
    /// - Throws: 假資料無法完整建立或 SwiftData 儲存失敗時拋出錯誤。
    static func seed(
        into context: ModelContext,
        referenceDate: Date = Date()
    ) throws {
        let expenses = makeExpenses(referenceDate: referenceDate)
        guard expenses.count == expenseCount else {
            throw MockExpenseDataError.invalidGeneratedCount
        }

        for expense in expenses {
            context.insert(expense)
        }

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

private enum MockExpenseDataError: Error {
    case invalidGeneratedCount
}
#endif
