import Foundation

struct DateHelper {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone.current
        
        return formatter
    }()
    
    static func string(from date: Date) -> String {
        return formatter.string(from: date)
    }
    
    static func date(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}
