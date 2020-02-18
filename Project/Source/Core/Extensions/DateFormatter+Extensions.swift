import Foundation

extension DateFormatter {

    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let hourMinuteMeridiem: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    //
    //  Anything that deals purely in a date (without a time) should be synced to GMT.
    //
    static let shortDayMonthDateGmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM d"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let shortDayMonthTimeGmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma, E MMM d"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let longDayMonthDateGmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let yearMonthDayGmt: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
