//
//  DateFormatter+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import Foundation

/// 提供 MoneyMate 預設的繁體中文日期格式器。
extension DateFormatter {
    /// 使用 `zh_TW` locale 並輸出「yyyy年M月d日」格式的共用 formatter。
    static let localized: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
}
