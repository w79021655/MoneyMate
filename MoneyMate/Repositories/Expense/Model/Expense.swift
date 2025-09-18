//
//  Expense.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/3.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Expense: Identifiable, Equatable, Decodable {

    /// 為一識別碼
    var id: UUID = UUID()

    /// 收入支出的金額
    var amount: Int

    /// 收入支出類型
    var category: Category

    /// 消費日期
    var date: Date

    /// 消費時間
    var dateTime: Date

    /// 備註
    var remark: String

    init(
        id: UUID = UUID(),
        amount: Int,
        category: Category,
        date: Date,
        dateTime: Date,
        remark: String
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.dateTime = dateTime
        self.remark = remark
    }

    required convenience init(from decoder: Decoder) throws {
        enum CodingKeys: String, CodingKey {
            case id, amount, category, date, dateTime, remark
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(UUID.self, forKey: .id)
        let amount = try container.decode(Int.self, forKey: .amount)
        let categoryRaw = try container.decode(String.self, forKey: .category)
        let category = Category(rawValue: categoryRaw) ?? .dining

        let dateStr = try container.decode(String.self, forKey: .date)
        let date = dateStr.convertToDate()

        let dateTimeStr = try container.decode(String.self, forKey: .dateTime)
        let dateTime = dateTimeStr.convertToDate()

        let remark = try container.decode(String.self, forKey: .remark)

        self.init(id: id, amount: amount, category: category, date: date, dateTime: dateTime, remark: remark)
    }
}

/// 自動指向 Expense.date
extension Expense: DateRepresentable {}
