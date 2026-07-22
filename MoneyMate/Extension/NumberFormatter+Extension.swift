//
//  NumberFormatter+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import Foundation

/// 提供 MoneyMate 數字顯示使用的共用 formatter。
extension NumberFormatter {
    /// 以逗號分組、但不附加貨幣符號的十進位 formatter。
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}
