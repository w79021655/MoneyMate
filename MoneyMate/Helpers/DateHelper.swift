//
//  DateHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation

/// 集中處理 MoneyMate 支援的日期格式解析、輸出與比較。
class DateHelper {

    static let shared = DateHelper()

    private lazy var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private lazy var inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private lazy var outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private lazy var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - 格式轉換

/// 提供日期字串與 `Date` 之間的格式轉換。
extension DateHelper {

    /// 將支援格式的日期字串轉換為指定輸出格式。
    /// - Parameters:
    ///   - dateString: 來源日期字串
    ///   - format: 目標日期格式
    /// - Returns: 轉換後的日期字串，若解析失敗則回傳 `nil`
    func convertFlexibleStringFormat(dateString: String, to format: DateFormat) -> String? {
        let possibleFormats = DateFormat.allFormats

        guard let parsedDate = possibleFormats.compactMap({ formatString -> Date? in
            inputFormatter.dateFormat = formatString
            return inputFormatter.date(from: dateString)
        }).first else {
            return nil
        }

        // 設定輸出格式
        outputFormatter.dateFormat = format.rawValue
        return outputFormatter.string(from: parsedDate)
    }

    /// 將 `Date` 轉換為指定格式的日期字串。
    /// - Parameters:
    ///   - date: 要格式化的日期。
    ///   - format: 目標日期格式。
    /// - Returns: 格式化後的日期字串。
    func convertFlexibleDateFormatToString(date: Date, to format: DateFormat) -> String? {
        let possibleFormats = DateFormat.allFormats

        return possibleFormats.compactMap { formatString -> String? in
            outputFormatter.dateFormat = format.rawValue
            return outputFormatter.string(from: date)
        }.first
    }

    /// 依序嘗試所有支援格式，將日期字串解析成 `Date`。
    /// - Parameter dateString: 日期字串
    /// - Returns: 轉換成功的 `Date`，解析失敗則回傳 `nil`
    func convertFlexibleStringFormatToDate(dateString: String) -> Date? {
        let possibleFormats = DateFormat.allFormats

        return possibleFormats.compactMap { formatString -> Date? in
            inputFormatter.dateFormat = formatString
            return inputFormatter.date(from: dateString)
        }.first
    }
}

// MARK: - 驗證與比較

/// 提供日期區間驗證與日數比較。
extension DateHelper {

    /// 檢查目前時間是否位於指定的 ISO 8601 字串區間內。
    /// - Parameters:
    ///   - startDateTime: 開始時間 (ISO8601 格式字串)
    ///   - endDateTime: 結束時間 (ISO8601 格式字串)
    /// - Returns: 是否在時間範圍內
    func isCurrentTimeInRange(startDateTime: String, endDateTime: String) -> Bool {
        guard let startDate = isoFormatter.date(from: startDateTime),
              let endDate = isoFormatter.date(from: endDateTime) else {
            return false
        }
        return isCurrentTimeInRange(startDate: startDate, endDate: endDate)
    }

    /// 檢查目前時間是否位於指定日期區間內，並包含起訖時間。
    /// - Parameters:
    ///   - startDate: 開始時間 (`Date`)
    ///   - endDate: 結束時間 (`Date`)
    /// - Returns: 是否在時間範圍內
    private func isCurrentTimeInRange(startDate: Date, endDate: Date) -> Bool {
        let currentDate = Date()
        return currentDate >= startDate && currentDate <= endDate
    }

    /// 判斷目標日期與參考日期的日數差是否小於指定門檻。
    /// - Parameters:
    ///   - targetDate: 需要比較的日期
    ///   - referenceDate: 參考日期 (當前時間)
    ///   - diffDay: 超過天數預設值
    /// - Returns: `true` 代表在 N 天內，`false` 代表超過 N 天
    func isDateWithinOneDay(targetDate: Date, referenceDate: Date = Date(), diffDay: Int) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let diff = calendar.dateComponents([.day], from: targetDate, to: referenceDate)
        return (diff.day ?? 0) < diffDay
    }

    /// 計算起始日期與結束日期之間的天數差異。
    /// - Parameters:
    ///   - startDate: 開始日期，與結束日期進行比較。
    ///   - endDate: 結束日期，與當前日期進行比較。
    ///   - dateFormat: 日期格式，預設為 "yyyy/MM/dd"。
    /// - Returns: 起始日期與結束日期相差的天數。
    func dateCompare(startDate: Date, endDate: Date, dateFormat: String = "yyyy/MM/dd") -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let startDateStr = formatter.string(from: startDate)
        let endDateStr = formatter.string(from: endDate)
        let sDate = formatter.date(from: startDateStr) ?? Date()
        let eDate = formatter.date(from: endDateStr) ?? Date()

        let calendar = Calendar.current
        let diff: DateComponents = calendar.dateComponents([.day], from: sDate, to: eDate)

        return diff.day!
    }
}

// MARK: - 日期運算

/// 提供日期位移與星期顯示能力。
extension DateHelper {

    /// 將指定日期往前或往後移動天數。
    /// - Parameters:
    ///   - to: 位移的基準日期。
    ///   - interval: 位移天數；正值往後，負值往前。
    /// - Returns: 位移後的日期；計算失敗時回退為目前時間。
    func addDay(to: Date, for interval: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = interval

        return Calendar.current.date(byAdding: dateComponent, to: to) ?? Date()
    }

    /// 取得日期對應的星期幾 (例如 "一", "二", "三"...)
    /// - Parameter dateString: 來源日期字串
    /// - Returns: 對應的星期幾 (字串)，解析失敗則回傳 `nil`
    func getWeekday(from dateString: String) -> String? {
        guard let date = convertFlexibleStringFormatToDate(dateString: dateString) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let weekdayIndex = calendar.component(.weekday, from: date)

        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        return weekdays[weekdayIndex - 1]
    }
}

// MARK: - 日期格式

/// 列出 `DateHelper` 可解析或輸出的日期格式。
enum DateFormat: String, CaseIterable {

    // 標準格式

    /// yyyy-MM-dd'T'HH:mm:ss.SSSXXX
    case fullWithMillisecondsAndTimezone = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"

    /// yyyy-MM-dd'T'HH:mm:ssXXX
    case fullWithTimezone = "yyyy-MM-dd'T'HH:mm:ssXXX"

    /// yyyy-MM-dd'T'HH:mm:ss
    case fullWithoutTimezone = "yyyy-MM-dd'T'HH:mm:ss"

    /// yyyy-MM-dd HH:mm:ss
    case dateTimeWithSeconds = "yyyy-MM-dd HH:mm:ss"

    /// yyyy-MM-dd HH:mm
    case dateTimeWithoutSeconds = "yyyy-MM-dd HH:mm"

    /// yyyy-MM-dd
    case onlyDate = "yyyy-MM-dd"

    /// HH:mm:ss
    case onlyTimeWithSeconds = "HH:mm:ss"

    /// HH:mm
    case onlyTimeWithoutSeconds = "HH:mm"

    // 帶 `/` 的格式

    /// yyyy/MM/dd HH:mm:ss
    case fullDateTimeWithSecondsSlash = "yyyy/MM/dd HH:mm:ss"

    /// yyyy/MM/dd HH:mm
    case fullDateTimeWithoutSecondsSlash = "yyyy/MM/dd HH:mm"

    /// yyyy/MM/dd
    case onlyDateSlash = "yyyy/MM/dd"

    // `.` 分隔格式

    /// yyyy.MM.dd
    case onlyDateDot = "yyyy.MM.dd"

    /// yyyy.MM.dd HH:mm
    case dateTimeWithoutSecondsOnlyDot = "yyyy.MM.dd HH:mm"

    /// none
    case none = ""

    /// 提供日期解析時依序嘗試的所有格式字串。
    static var allFormats: [String] {
        return DateFormat.allCases.map { $0.rawValue }
    }
}
