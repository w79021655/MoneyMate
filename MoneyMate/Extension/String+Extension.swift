//
//  String+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation

/// 提供日期字串解析、轉換與星期顯示能力。
extension String {

    /// 將可辨識的日期字串轉換為指定格式。
    /// - Parameter format: 目標日期格式。
    /// - Returns: 轉換後的日期字串；解析失敗時回傳 `nil`。
    func convertFlexibleStringFormat(to format: DateFormat) -> String? {
        dateHelper.convertFlexibleStringFormat(dateString: self, to: format)
    }

    /// 將可辨識的日期字串解析為 `Date`。
    /// - Returns: 解析結果；失敗時回退為呼叫當下的時間。
    func convertToDate() -> Date {
        dateHelper.convertFlexibleStringFormatToDate(dateString: self) ?? Date()
    }

    /// 取得日期字串所對應的中文星期簡稱。
    /// - Returns: 「日」至「六」其中一值；日期無法解析時回傳 `nil`。
    func getWeekday() -> String? {
        dateHelper.getWeekday(from: self)
    }
}
