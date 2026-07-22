//
//  AppDefine.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/5.
//

/// 提供全域共用的日期解析與格式轉換能力。
let dateHelper = DateHelper.shared

/// 提供全域共用的 JSON 解碼能力。
let codableHelper: CodableHelper = CodableHelper.shared

/// 表示以字串為鍵的通用請求參數集合。
typealias Parameters = [String: Any]

/// 表示不接收參數且不回傳值的同步操作。
typealias EmptyClosure = (() -> Void)
