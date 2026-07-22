//
//  View+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2026/1/12.
//

import SwiftUI

/// 提供 MoneyMate 共用的 View 樣式。
extension View {

    /// 套用統一的卡片圓角與陰影效果。
    /// - Returns: 套用卡片外觀後的 View。
    func cardStyle() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.Shadow.card, radius: 4, x: 0, y: 2)
    }
}
