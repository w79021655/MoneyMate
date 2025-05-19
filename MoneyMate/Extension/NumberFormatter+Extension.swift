//
//  NumberFormatter+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/16.
//

import Foundation

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}
