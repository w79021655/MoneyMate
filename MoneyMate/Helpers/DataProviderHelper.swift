//
//  DataProviderHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/5.
//

import Foundation
import SwiftData

/// `DataProviderHelper` 提供 SwiftData 常用操作的泛型封裝，包括資料查詢、新增、刪除等功能。
/// 透過靜態方法與泛型支援，減少重複程式碼，提高資料操作一致性與可讀性。
struct DataProviderHelper {

    static let shared = DataProviderHelper()

    /// 依據指定條件查詢資料模型集合。
    /// - Parameters:
    ///   - context: 使用的 ModelContext。
    ///   - predicate: 篩選條件（可選）。
    ///   - sortBy: 排序條件（可選）。
    /// - Returns: 查詢結果陣列。
    func fetch<T: PersistentModel>(
        from context: ModelContext,
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) -> [T] {
        let descriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortBy
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// 將模型資料插入至指定的 context。
    /// - Parameters:
    ///   - model: 欲插入的 PersistentModel 實例。
    ///   - context: 使用的 ModelContext。
    func insert<T: PersistentModel>(_ model: T, into context: ModelContext) {
        context.insert(model)
    }

    /// 從指定 context 中刪除特定模型實例。
    /// - Parameters:
    ///   - model: 欲刪除的 PersistentModel 實例。
    ///   - context: 使用的 ModelContext。
    func delete<T: PersistentModel>(_ model: T, from context: ModelContext) {
        context.delete(model)
    }

    /// 刪除某類型的所有資料。
    /// - Parameters:
    ///   - type: 資料模型類型。
    ///   - context: 使用的 ModelContext。
    func deleteAll<T: PersistentModel>(of type: T.Type, from context: ModelContext) {
        let allItems = fetch(from: context) as [T]
        for item in allItems {
            context.delete(item)
        }
    }

    /// 透過 PersistentIdentifier 刪除特定模型。
    /// - Parameters:
    ///   - type: 資料模型類型。
    ///   - id: 模型的 PersistentIdentifier。
    ///   - context: 使用的 ModelContext。
    func deleteById<T: PersistentModel>(_ type: T.Type,
                                        id: PersistentIdentifier,
                                        from context: ModelContext) {
        guard let item = context.model(for: id) as? T else { return }
        context.delete(item)
    }
}

extension DataProviderHelper {

    /// 查詢某一日期所在月份內的所有資料（需符合 DateRepresentable）。
    /// - Parameters:
    ///   - context: 使用的 ModelContext。
    ///   - startDate: 所屬查詢月份的日期（任何該月內的日期皆可）。
    /// - Returns: 符合該月份的資料集合。
    func fetchThisMonth<T: PersistentModel & DateRepresentable>(
        from context: ModelContext,
        startDate: Date
    ) -> [T] {
        let calendar = Calendar.current
        guard let range = calendar.dateInterval(of: .month, for: startDate) else { return [] }
        let predicate = #Predicate<T> { $0.date >= range.start && $0.date < range.end }
        let sort = [SortDescriptor(\T.date, order: .reverse)]
        return fetch(from: context, predicate: predicate, sortBy: sort)
    }
}
