//
//  CodableHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation

/// 將通用 JSON 輸入解碼為指定 `Decodable` 型別。
struct CodableHelper {

    static let shared: CodableHelper = CodableHelper()

    private var decoder: JSONDecoder

    /// 建立共用 decoder；限制由 `shared` 統一提供實例。
    private init() {
        decoder = JSONDecoder()
    }

    /// 將 JSON 字典解碼為指定模型。
    /// - Parameters:
    ///   - dictionary: 可由 `JSONSerialization` 序列化的字典。
    ///   - type: 目標 `Decodable` 型別。
    /// - Returns: 解碼後的模型；序列化或解碼失敗時回傳 `nil`。
    public func decode<T: Decodable>(from dictionary: Dictionary<String, Any>,
                                     type: T.Type) -> T? {
        guard let data = dictionary.data else {
            return nil
        }

        return decode(from: data, type: type)
    }

    /// 將 JSON 字典陣列解碼為指定模型。
    /// - Parameters:
    ///   - array: 可由 `JSONSerialization` 序列化的字典陣列。
    ///   - type: 目標 `Decodable` 型別。
    /// - Returns: 解碼後的模型；序列化或解碼失敗時回傳 `nil`。
    public func decode<T: Decodable>(from array: [Dictionary<String, Any>],
                                     type: T.Type) -> T? {
        guard let data = array.data else {
            print("CodableHelper dictionary convert data nil")
            return nil
        }

        return decode(from: data, type: type)
    }

    /// 將 JSON `Data` 解碼為指定模型。
    /// - Parameters:
    ///   - data: JSON 編碼的資料。
    ///   - type: 目標 `Decodable` 型別。
    /// - Returns: 解碼後的模型；解碼失敗時回傳 `nil`。
    public func decode<T: Decodable>(from data: Data, type: T.Type) -> T? {
        do {
            let t = try decoder.decode(type.self, from: data)
            return t
        } catch _ {
            return nil
        }
    }
}
