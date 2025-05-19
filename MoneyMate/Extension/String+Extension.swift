//
//  String+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation

extension String {

    /// 將日期特定格式`String`轉換為其他指定`String`格式
    /// - Parameters:
    ///   - format: 目標日期格式
    /// - Returns: 轉換後的日期字串，若解析失敗則回傳 `nil`
    func convertFlexibleStringFormat(to format: DateFormat) -> String? {
        dateHelper.convertFlexibleStringFormat(dateString: self, to: format)
    }

    /// 將日期特定格式`String`解析為 `Date`
    /// - Returns: 轉換成功的 `Date`，解析失敗則回傳 `nil`
    func convertToDate() -> Date {
        dateHelper.convertFlexibleStringFormatToDate(dateString: self) ?? Date()
    }

    /// 根據日期取得當周日
    func getWeekday() -> String? {
        dateHelper.getWeekday(from: self)
    }
}
