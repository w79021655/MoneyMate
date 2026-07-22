//
//  Representable.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/5.
//

import Foundation

/// 定義可提供單一日期排序或篩選值的型別。
protocol DateRepresentable {
    /// 此資料在通用日期操作中使用的基準日期。
    var date: Date { get }
}
