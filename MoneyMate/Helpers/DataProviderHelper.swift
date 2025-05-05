//
//  DataProviderHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/5.
//

import Foundation
import SwiftData

struct DataProviderHelper {

    static let shared = DataProviderHelper()

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

    func insert<T: PersistentModel>(_ model: T, into context: ModelContext) {
        context.insert(model)
    }
}

extension DataProviderHelper {

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
