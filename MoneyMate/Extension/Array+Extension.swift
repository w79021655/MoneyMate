//
//  Array+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import Foundation

// MARK: General Extension

extension Array {

    /// 回傳一個空陣列。
    static var empty: Self { [] }

    /// 是否為非空陣列。
    var isNotEmpty: Bool { !self.isEmpty }

    /// 將陣列轉換為 JSON 格式的 `Data`。
    var data: Data? { try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) }
}

// MARK: String-Specific Extension

extension Array where Element == String {

    /// 將陣列中的字串依指定的分隔符組合成一個地址字串。
    /// - Parameter separator: 用來分隔各字串的分隔符，預設為空字串。
    /// - Returns: 組合後的地址字串。
    func joinedString(separator: String = "") -> String {
        self.compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }
}

extension Array where Element == String? {

    /// 將陣列中的字串依指定的分隔符組合成一個地址字串。
    /// - Parameter separator: 用來分隔各字串的分隔符，預設為空字串。
    /// - Returns: 組合後的地址字串。
    func joinedString(separator: String = "") -> String {
        self.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }
}
