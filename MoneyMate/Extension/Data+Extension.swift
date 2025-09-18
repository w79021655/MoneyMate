//
//  Data+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation

extension Data {

    /// 將 `Data` 轉換為字串。
    /// - Returns: 回傳 UTF-8 編碼的字串；失敗，回傳 `nil`。
    var string: String? { String(data: self, encoding: .utf8) }

    /// 將 `Data` 轉換為字典。
    /// - Returns: 回傳包含鍵值對的字典；失敗，回傳 `nil`。
    var dictionary: Dictionary<String, Any>? {
        if let obj = try? JSONSerialization.jsonObject(with: self,
                                                       options: .mutableContainers),
            let json = obj as? Dictionary<String, Any> {
            return json
        }

        return nil
    }
}
