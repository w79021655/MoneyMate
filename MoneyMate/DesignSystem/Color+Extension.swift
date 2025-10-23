//
//  Color+.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/11.
//

import SwiftUI

extension Color {

    enum Brand {
        static let primary = Color(hex: "#2196F3")   // 藍色區塊
        static let accent = Color(hex: "#64B5F6")    // 進度條填滿
        static let subtleRGB = Color(r: 200, g: 200, b: 200, a: 0.3)
    }

    enum Text {
        static let primary = Color(hex: "#000000")   // 主文字的黑深色
        static let secondary = Color(hex: "#999999") // 次要主要文字
        static let inverse = Color(hex: "#FFFFFF") // 反白
        static let negative = Color(hex: "#E53935") // 支出用紅色
    }

    enum Background {
        static let card = Color(hex: "#FFFFFF")
        static let screen = Color(hex: "#F5F5F5")
    }

    enum Border {
        static let loading = Color(hex: "#2196F3")
        static let subtle = Color(hex: "#E0E0E0")
    }

    enum Shadow {
        static let card = Color.black.opacity(0.03)
    }

    enum Fill {
        static let progress = Color.Brand.accent
    }

    enum Category {
        static let transport = Color(hex: "#42A5F5") // 交通
        static let game = Color(hex: "#FFB74D")      // 手遊
        static let shopping = Color(hex: "#F48FB1")  // 購物
        static let gift = Color(hex: "#FFD54F")      // 禮品
        static let food = Color(hex: "#FF8A65")      // 餐飲
    }
}

// MARK: Hex

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hex.count {
        case 6: // RGB
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1.0
        case 8: // RGBA
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255
        default:
            r = 1; g = 1; b = 1; a = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: RGBA

extension Color {
    init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.init(
            .sRGB,
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            opacity: a
        )
    }
}
