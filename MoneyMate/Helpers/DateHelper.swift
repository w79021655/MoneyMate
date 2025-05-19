//
//  DateHelper.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/17.
//

import Foundation

/// 日期格式處理 & 轉換
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

// MARK: Format conversion

extension DateHelper {

    /// 將日期特定格式`String`轉換為其他指定`String`格式
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

    /// 將`Date`轉換為指定`String`日期格式
    /// - Parameter date: 日期字串
    /// - format: 目標日期格式
    /// - Returns: 轉換成功的 `Date`，解析失敗則回傳 `nil`
    func convertFlexibleDateFormatToString(date: Date, to format: DateFormat) -> String? {
        let possibleFormats = DateFormat.allFormats

        return possibleFormats.compactMap { formatString -> String? in
            outputFormatter.dateFormat = format.rawValue
            return outputFormatter.string(from: date)
        }.first
    }

    /// 將多種日期格式並解析成 `Date`
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

// MARK: Validation & Checks

extension DateHelper {

    /// 檢查當前時間是否在指定範圍內 (使用 String)
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

    /// 檢查當前時間是否在指定範圍內 (使用 Date)
    /// - Parameters:
    ///   - startDate: 開始時間 (`Date`)
    ///   - endDate: 結束時間 (`Date`)
    /// - Returns: 是否在時間範圍內
    private func isCurrentTimeInRange(startDate: Date, endDate: Date) -> Bool {
        let currentDate = Date()
        return currentDate >= startDate && currentDate <= endDate
    }

    /// 判斷 `targetDate` 是否在 `referenceDate` 日期區間範圍內
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

// MARK: Function

extension DateHelper {

    /// 針對當前日期做天數 +, -
    /// - Parameter to: 當前日期
    /// - Parameter interval: 天數
    /// - Returns: Date
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

// MARK: Enum

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

    static var allFormats: [String] {
        return DateFormat.allCases.map { $0.rawValue }
    }
}
