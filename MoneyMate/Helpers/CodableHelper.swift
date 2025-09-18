//
//  CodableHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import Foundation

/// JSONDecoder 幫助類
struct CodableHelper {

    static let shared: CodableHelper = CodableHelper()

    private var decoder: JSONDecoder

    private init() {
        decoder = JSONDecoder()
    }

    /// 解析Dictionary<String, Any> to Model
    /// - Parameters:
    ///   - data: Api return dictionary
    ///   - type: e.g. Agent ...etc
    public func decode<T: Decodable>(from dictionary: Dictionary<String, Any>,
                                     type: T.Type) -> T? {
        guard let data = dictionary.data else {
            return nil
        }

        return decode(from: data, type: type)
    }

    /// 解析Array<Dictionary<String, Any>> to Model
    /// - Parameters:
    ///   - array: Api return dictionary of array
    ///   - type: e.g. Agent ...etc
    public func decode<T: Decodable>(from array: [Dictionary<String, Any>],
                                     type: T.Type) -> T? {
        guard let data = array.data else {
            print("CodableHelper dictionary convert data nil")
            return nil
        }

        return decode(from: data, type: type)
    }

    /// 解析Data to Model
    /// - Parameters:
    ///   - data: Api return dictionary and convert to data
    ///   - type: e.g. Agent ...etc
    public func decode<T: Decodable>(from data: Data, type: T.Type) -> T? {
        do {
            let t = try decoder.decode(type.self, from: data)
            return t
        } catch _ {
            return nil
        }
    }
}
