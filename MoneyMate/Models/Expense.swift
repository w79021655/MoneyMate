//
//  Expense.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/3.
//

import Foundation
import SwiftData
import SwiftUICore

@Model
class Expense: Identifiable, Equatable {

    /// 為一識別碼
    var id: UUID = UUID()

    /// 收入支出的金額
    var amount: Int

    /// 收入支出類型
    var category: Category

    /// 消費日期
    var date: Date

    /// 消費時間
    var dateTime: Date

    /// 備註
    var remark: String

    init(
        id: UUID = UUID(),
        amount: Int,
        category: Category,
        date: Date,
        dateTime: Date,
        remark: String
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.dateTime = dateTime
        self.remark = remark
    }
}

extension Expense {
    static func fetchAll(from context: ModelContext) throws -> [Expense] {
        let descriptor = FetchDescriptor<Expense>()
        return try context.fetch(descriptor)
    }

    func delete(from context: ModelContext) {
        context.delete(self)
    }
}

// MARK: Enum

enum Category: String, CaseIterable, Identifiable, Codable {
    // 支出類別
    case dining = "餐飲"
    case clothing = "服裝"
    case fruits = "水果"
    case shopping = "購物"
    case transport = "交通"
    case home = "家"
    case travel = "旅行"
    case alcohol = "酒類"
    case utilities = "水電費"
    case gift = "禮品"
    case education = "教育"
    case snacks = "小吃"
    case phone = "電話費"
    case children = "孩子"
    case fitness = "運動"
    case tax = "稅"
    case electronics = "電子產品"
    case health = "健康"
    case entertainment = "娛樂"
    case car = "車"
    case social = "社交"
    case insurance = "保險"
    case office = "辦公"
    case smoking = "香菸"
    case pets = "寵物"
    case beauty = "美容"

    // 收入類別
    case salary = "薪水"
    case rental = "出租"
    case donation = "捐贈"
    case dividend = "股息"

    var id: String { self.rawValue }

    var systemImageName: String {
        switch self {
        case .dining: "fork.knife"
        case .clothing: "tshirt"
        case .fruits: "applelogo"
        case .shopping: "bag"
        case .transport: "bus"
        case .home: "house"
        case .travel: "airplane"
        case .alcohol: "wineglass"
        case .utilities: "bolt.fill"
        case .gift: "gift"
        case .education: "book"
        case .snacks: "cup.and.saucer"
        case .phone: "phone"
        case .children: "figure.and.child.holdinghands"
        case .fitness: "dumbbell"
        case .tax: "doc.plaintext"
        case .electronics: "desktopcomputer"
        case .health: "cross.case"
        case .entertainment: "gamecontroller"
        case .car: "car"
        case .social: "person.2"
        case .insurance: "shield"
        case .office: "paperclip"
        case .smoking: "smoke"
        case .pets: "pawprint"
        case .beauty: "scissors"
        case .salary: "creditcard"
        case .rental: "building"
        case .donation: "hands.sparkles"
        case .dividend: "chart.bar"
        }
    }

    var color: Color {
        switch self {
        case .dining: return .orange
        case .clothing: return .pink
        case .fruits: return .green
        case .shopping: return .purple
        case .transport: return .blue
        case .home: return .teal
        case .travel: return .cyan
        case .alcohol: return .indigo
        case .utilities: return .gray
        case .gift: return .red
        case .education: return .mint
        case .snacks: return .yellow
        case .phone: return .blue
        case .children: return .orange
        case .fitness: return .green
        case .tax: return .brown
        case .electronics: return .black
        case .health: return .pink
        case .entertainment: return .purple
        case .car: return .blue
        case .social: return .indigo
        case .insurance: return .gray
        case .office: return .brown
        case .smoking: return .gray
        case .pets: return .teal
        case .beauty: return .pink
        case .salary: return .green
        case .rental: return .cyan
        case .donation: return .yellow
        case .dividend: return .mint
        }
    }
}

/// 自動指向 Expense.date
extension Expense: DateRepresentable {}
