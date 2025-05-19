//
//  Date+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation

extension Date {

    /// 針對當前日期做天數 +, -
    /// - Parameter interval: 天數
    /// - Returns: Date
    func addDay(for interval: Int) -> Date { dateHelper.addDay(to: self, for: interval) }

    /// 計算起始日期與結束日期之間的天數差異。
    /// - Parameters:
    ///   - endDate: 結束日期，與當前日期進行比較。
    ///   - dateFormat: 日期格式，預設為 "yyyy/MM/dd"。
    /// - Returns: 起始日期與結束日期相差的天數。
    func dateCompare(endDate: Date, dateFormat: String = "yyyy/MM/dd") -> Int {
        dateHelper.dateCompare(startDate: self, endDate: endDate, dateFormat: dateFormat)
    }

    /// 將`Date`轉換為指定`String`日期格式
    /// - Parameter dateFormat: 日期格式
    /// - Returns: 轉換成功的 `Date`，解析失敗則回傳 `nil`
    func convertToString(dateFormat: String = "yyyy/MM/dd") -> String? {
        dateHelper.convertFlexibleDateFormatToString(date: self, to: DateFormat(rawValue: dateFormat) ?? .fullDateTimeWithSecondsSlash)
    }
}
