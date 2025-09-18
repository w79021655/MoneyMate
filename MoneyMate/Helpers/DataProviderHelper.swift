//
//  DataProviderHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/5.
//

import Foundation
import SwiftData

/// `DataProviderHelper` 提供 SwiftData 常用操作的泛型封裝，包括資料查詢、新增、刪除等功能
/// 透過靜態方法與泛型支援，減少重複程式碼，提高資料操作一致性與可讀性
struct DataProviderHelper {

    static let shared = DataProviderHelper()

    /// 依據指定條件查詢資料模型集合
    /// - Parameters:
    ///   - predicate: 篩選條件（可選）
    ///   - sortBy: 排序條件（可選）
    ///   - limit: 排序條件（可選）
    /// - Returns: 查詢結果陣列
    func fetch<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = [],
        limit: Int = 0
    ) async -> [T] {
        var descriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortBy
        )

        if limit > 0 {
            descriptor.fetchLimit = limit
        }
        return (try? modelContextProvider.context.fetch(descriptor)) ?? []
    }

    /// 將模型資料插入至指定的 context
    /// - Parameters:
    ///   - model: 欲插入的 PersistentModel 實例
    func insert<T: PersistentModel>(_ model: T) async {
        modelContextProvider.context.insert(model)
    }

    /// 從指定 context 中刪除特定模型實例
    /// - Parameters:
    ///   - model: 欲刪除的 PersistentModel 實例
    func delete<T: PersistentModel>(_ model: T) async {
        modelContextProvider.context.delete(model)
    }

    /// 刪除某類型的所有資料
    /// - Parameters:
    ///   - type: 資料模型類型
    func deleteAll<T: PersistentModel>(of type: T.Type) async {
        let allItems = await fetch() as [T]
        for item in allItems {
            modelContextProvider.context.delete(item)
        }
    }

    /// 透過 PersistentIdentifier 刪除特定模型
    /// - Parameters:
    ///   - type: 資料模型類型
    ///   - id: 模型的 PersistentIdentifier
    func deleteById<T: PersistentModel>(_ type: T.Type,
                                        id: PersistentIdentifier) async {
        guard let item = modelContextProvider.context.model(for: id) as? T else { return }
        modelContextProvider.context.delete(item)
    }
}

extension DataProviderHelper {

    /// 查詢某一日期所在月份內的所有資料（需符合 DateRepresentable）。
    /// - Parameters:
    ///   - startDate: 所屬查詢月份的日期（任何該月內的日期皆可）。
    /// - Returns: 符合該月份的資料集合。
    func fetchThisMonth<T: PersistentModel & DateRepresentable>(startDate: Date) async -> [T] {
        let calendar = Calendar.current
        guard let range = calendar.dateInterval(of: .month, for: startDate) else { return [] }
        let predicate = #Predicate<T> { $0.date >= range.start && $0.date < range.end }
        let sort = [SortDescriptor(\T.date, order: .reverse)]
        return await fetch(predicate: predicate, sortBy: sort)
    }


    /// 分頁查詢資料，依據指定起始日期往後抓取指定筆數的資料（需符合 DateRepresentable）
    /// - Parameters:
    ///   - startDate: 起始查詢日期（不含）
    ///   - limit: 取得的筆數上限，預設為 20
    /// - Returns: 依照日期遞減排序的資料集合
    func fetchPaginatedAfterDate<T: PersistentModel & DateRepresentable>(
        startDate: Date,
        limit: Int = 20
    ) async -> [T] {
        let predicate = #Predicate<T> {
            $0.date < startDate
        }
        let sort = [SortDescriptor(\T.date, order: .reverse)]
        return await fetch(predicate: predicate, sortBy: sort, limit: limit)
    }
}
