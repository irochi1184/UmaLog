import Foundation

enum AmountFormatting {
    static func groupedFormatter(locale: Locale = .autoupdatingCurrent) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }

    static func plainFormatter(locale: Locale = .autoupdatingCurrent) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter
    }

    static func currency(_ value: Double, locale: Locale = .autoupdatingCurrent, currencyCode: String = "JPY") -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "¥0"
    }

    static func parseAmount(_ text: String, locale: Locale = .autoupdatingCurrent) -> Double? {
        let grouped = groupedFormatter(locale: locale)
        if let number = grouped.number(from: text)?.doubleValue {
            return number
        }
        let grouping = grouped.groupingSeparator ?? ","
        let sanitized = text
            .replacingOccurrences(of: grouping, with: "")
            .replacingOccurrences(of: " ", with: "")
        return Double(sanitized)
    }
}
