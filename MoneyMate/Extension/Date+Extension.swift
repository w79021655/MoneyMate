//
//  Date+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation

/// MoneyMate 畫面統一使用的繁體中文日期格式。
enum AppDateFormat {
    /// 僅顯示年月，例如「2025年8月」。
    static let yearMonth = Date.FormatStyle.dateTime
        .year()
        .month()
        .locale(Locale(identifier: "zh_TW"))

    /// 顯示年月日，例如「2025年8月24日」。
    static let yearMonthDay = Date.FormatStyle.dateTime
        .year()
        .month()
        .day()
        .locale(Locale(identifier: "zh_TW"))
}

/// 將常用日期運算與格式轉換代理至共用的 `DateHelper`。
extension Date {

    /// 將目前日期往前或往後移動指定天數。
    /// - Parameter interval: 位移天數；正值往後，負值往前。
    /// - Returns: 位移後的日期；無法計算時由 `DateHelper` 回退為目前時間。
    func addDay(for interval: Int) -> Date { dateHelper.addDay(to: self, for: interval) }

    /// 計算起始日期與結束日期之間的天數差異。
    /// - Parameters:
    ///   - endDate: 結束日期，與當前日期進行比較。
    ///   - dateFormat: 日期格式，預設為 "yyyy/MM/dd"。
    /// - Returns: 起始日期與結束日期相差的天數。
    func dateCompare(endDate: Date, dateFormat: String = "yyyy/MM/dd") -> Int {
        dateHelper.dateCompare(startDate: self, endDate: endDate, dateFormat: dateFormat)
    }

    /// 將日期轉換為指定格式的字串。
    /// - Parameter dateFormat: `DateFormat` 支援的日期格式字串。
    /// - Returns: 格式化後的日期字串。
    func convertToString(dateFormat: String = "yyyy/MM/dd") -> String? {
        dateHelper.convertFlexibleDateFormatToString(date: self, to: DateFormat(rawValue: dateFormat) ?? .fullDateTimeWithSecondsSlash)
    }
}
