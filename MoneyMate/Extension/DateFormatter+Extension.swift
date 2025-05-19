//
//  DateFormatter+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import Foundation

extension DateFormatter {
    static let localized: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
}
