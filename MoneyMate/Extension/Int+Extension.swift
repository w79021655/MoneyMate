//
//  Int+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//


import Foundation

extension Int {

    /// 將整數轉換為字串
    /// - Returns: 整數的字串表示。
    var string: String { String(self) }

    /// 將整數轉換為 `CGFloat`
    /// - Returns: 與該整數值相等的 `CGFloat` 值。
    var cgfloat: CGFloat { CGFloat(self) }

    /// 格式化整數為含千分位的字串
    /// - Returns: 格式化後的字串，如 `"150000"` 轉換為 `"150,000"`，若格式化失敗則返回原數值的字串表示。
    /// - Note: 使用逗號作為千分位分隔符。
    func formatDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
