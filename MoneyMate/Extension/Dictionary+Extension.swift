//
//  Dictionary+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation

extension Dictionary {

    /// 將 `Dictionary` 轉換為 `Data`。
    /// - Returns: 如果轉換成功，回傳對應的 `Data`；若轉換失敗，回傳 `nil`。
    var data: Data? { try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) }

    /// 將 `Dictionary` 轉換為 JSON 格式的字串。
    /// - Returns: 如果轉換成功，回傳對應的 JSON 字串；若轉換失敗，回傳空字串 (`""`)。
    var string: String {
        guard let data = self.data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
