//
//  ExpenseRepositoryProtocol.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/9/16.
//

import SwiftUI
import Foundation
import SwiftData

/// 表示分頁查詢中最後一筆記帳的穩定位置。
///
/// 日期與 UUID 必須和 repository 的複合排序順序一致。
struct ExpensePageCursor: Equatable {
    /// 上一頁最後一筆記帳的日期排序值。
    let date: Date

    /// 日期相同時用來維持穩定順序的第二排序值。
    let id: UUID
}

/// 封裝一頁記帳結果與下一頁狀態。
struct ExpensePage {
    /// 本頁依 repository 規定順序排列的記帳資料。
    let expenses: [Expense]

    /// 下一次查詢應傳入的位置；本頁無資料時可能為 `nil`。
    let nextCursor: ExpensePageCursor?

    /// 是否仍有尚未載入的後續資料。
    let hasMore: Bool
}

/// 定義 Main Actor 上的記帳 persistence 操作 contract。
@MainActor
protocol ExpenseRepositoryProtocol {

    /// 新增並儲存一筆記帳。
    /// - Parameter expense: 要新增的記帳資料。
    /// - Throws: Persistence 寫入失敗時拋出錯誤。
    func addExpense(_ expense: Expense) async throws

    /// 刪除所有記帳資料。
    /// - Throws: Persistence 查詢或寫入失敗時拋出錯誤。
    func deleteAll() async throws

    /// 依 persistent identifier 刪除記帳。
    /// - Parameter id: 目標記帳的 SwiftData identifier。
    /// - Throws: Persistence 寫入失敗時拋出錯誤。
    func deleteByPersistentId(_ id: PersistentIdentifier) async throws

    /// 查詢半開日期區間 `[start, end)` 內的所有記帳。
    /// - Parameter interval: 要查詢的日期區間。
    /// - Returns: 符合條件的記帳；呼叫端不得假設結果順序。
    /// - Throws: Persistence 查詢失敗時拋出錯誤。
    func fetchExpenses(in interval: DateInterval) async throws -> [Expense]

    /// 取得日期區間內、位於指定 cursor 之後的一頁記帳。
    /// - Parameters:
    ///   - interval: 要查詢的半開日期區間 `[start, end)`。
    ///   - cursor: 上一頁位置；`nil` 表示第一頁。
    ///   - limit: 單頁最多回傳筆數。
    /// - Returns: 分頁資料與下一頁狀態。
    /// - Throws: Persistence 查詢失敗時拋出錯誤。
    func fetchExpensePage(
        in interval: DateInterval,
        after cursor: ExpensePageCursor?,
        limit: Int
    ) async throws -> ExpensePage
}

/// 區分記帳資料屬於支出或收入。
enum TransactionType: String, CaseIterable, Identifiable, Codable {

    /// 支出
    case expenditure = "expenditure"

    /// 收入
    case income = "income"

    var id: String { self.rawValue }
}

/// 列出 MoneyMate 可選擇的記帳分類與其 UI metadata。
enum Category: String, CaseIterable, Identifiable, Codable {
    case dining = "吃飯"
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
    case salary = "薪水"
    case rental = "出租"
    case donation = "捐贈"
    case dividend = "股息"

    var id: String { self.rawValue }

    /// 分類在畫面上使用的 SF Symbol 名稱。
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

    /// 分類在畫面上使用的代表色彩。
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
