//
//  Font+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/11.
//

import SwiftUI

extension Font {

    // MARK: - Display
    static let displayLarge = Font.system(size: 34, weight: .bold)
    static let displayMedium = Font.system(size: 28, weight: .bold)
    static let displaySmall = Font.system(size: 22, weight: .semibold)

    // MARK: - Title
    static let titleExtraLarge = Font.system(size: 34, weight: .bold)
    static let titleLarge = Font.system(size: 24, weight: .semibold)
    static let titleMedium = Font.system(size: 18, weight: .medium)
    static let titleSmall = Font.system(size: 14, weight: .medium)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 20, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)

    // MARK: - Label / Caption
    static let labelLarge = Font.system(size: 14, weight: .semibold)
    static let labelSmall = Font.system(size: 12, weight: .semibold)

    // MARK: - Custom for Tag / Helper Text / Other
    static let tag = Font.system(size: 11, weight: .medium)
    static let helper = Font.system(size: 10, weight: .regular)
}
