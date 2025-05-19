//
//  ModelContextProvider.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/11.
//

import SwiftData

/// 提供全域可存取的 SwiftData ModelContext
/// 需由 View 於啟動時注入 context
final class ModelContextProvider {
    static let shared = ModelContextProvider()

    private init() {}

    private var _context: ModelContext?

    var context: ModelContext {
        guard let context = _context else {
            fatalError("ModelContext not configured. Please call configure(context:) first.")
        }
        return context
    }

    func configure(context: ModelContext) {
        self._context = context
    }
}
