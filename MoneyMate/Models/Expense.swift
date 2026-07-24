//
//  Expense.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/3.
//

import Foundation
import SwiftData
import SwiftUI

/// 表示跨 feature 共用的一筆持久化收入或支出紀錄。
@Model
class Expense: Identifiable, Equatable, Decodable {

    /// 跨查詢與分頁維持穩定識別的 UUID。
    var id: UUID = UUID()

    /// 以整數儲存的記帳金額；收入為正值，支出為負值。
    var amount: Int

    /// 使用者選擇的記帳分類。
    var category: Category

    /// 記帳的收入或支出類型，必須與 `amount` 的正負號一致。
    var type: TransactionType

    /// 用於月份查詢、排序與畫面顯示的記帳日期。
    var date: Date

    /// 記錄使用者選擇的完整日期與時間。
    var dateTime: Date

    /// 使用者輸入的記帳說明。
    var remark: String

    /// 建立一筆收入或支出紀錄。
    /// - Parameters:
    ///   - id: 穩定識別碼，預設建立新的 UUID。
    ///   - amount: 整數金額；收入使用正值，支出使用負值。
    ///   - category: 記帳分類。
    ///   - type: 收入或支出類型。
    ///   - date: 查詢與顯示使用的記帳日期。
    ///   - dateTime: 記帳的完整日期與時間。
    ///   - remark: 使用者輸入的備註。
    init(
        id: UUID = UUID(),
        amount: Int,
        category: Category,
        type: TransactionType,
        date: Date,
        dateTime: Date,
        remark: String
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.type = type
        self.date = date
        self.dateTime = dateTime
        self.remark = remark
    }

    /// 從既有 JSON 格式解碼記帳資料。
    ///
    /// 無法辨識的分類與類型會分別回退為 `.dining` 與 `.expenditure`；日期解析行為由 `String.convertToDate()` 決定。
    ///
    /// - Parameter decoder: 提供記帳欄位的 decoder。
    /// - Throws: 必要欄位不存在或型別不符時拋出解碼錯誤。
    required convenience init(from decoder: Decoder) throws {
        /// 定義 JSON payload 與 `Expense` 屬性的鍵值對應。
        enum CodingKeys: String, CodingKey {
            case id, amount, category, type, date, dateTime, remark
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(UUID.self, forKey: .id)
        let amount = try container.decode(Int.self, forKey: .amount)

        let categoryRaw = try container.decode(String.self, forKey: .category)
        let category = Category(rawValue: categoryRaw) ?? .dining

        let typeRaw = try container.decode(String.self, forKey: .type)
        let type = TransactionType(rawValue: typeRaw) ?? .expenditure

        let dateStr = try container.decode(String.self, forKey: .date)
        let date = dateStr.convertToDate()

        let dateTimeStr = try container.decode(String.self, forKey: .dateTime)
        let dateTime = dateTimeStr.convertToDate()

        let remark = try container.decode(String.self, forKey: .remark)

        self.init(id: id, amount: amount, category: category, type: type, date: date, dateTime: dateTime, remark: remark)
    }
}

/// 讓通用日期排序或篩選邏輯使用 `Expense.date` 作為日期來源。
extension Expense: DateRepresentable {}
