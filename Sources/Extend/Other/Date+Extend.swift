//
//  Date+Util.swift
//  Extend
//
//  Created by bujiandi on 2017/4/28.
//

import Foundation

// MARK: - 可以 + - 天、时、分、秒

extension TimeInterval {
    
//    public static func +(lhs: TimeInterval, rhs: Date) -> Date {
//        return Date(timeInterval: lhs, since:rhs)
//    }
//    public static func -(lhs: TimeInterval, rhs: Date) -> Date {
//        return Date(timeInterval: -lhs, since:rhs)
//    }
}

extension Date {
    
    @inlinable public static func +(lhs: Date, rhs: TimeInterval) -> Date {
        return Date(timeInterval: rhs, since:lhs)
    }
    @inlinable public static func -(lhs: Date, rhs: TimeInterval) -> Date {
        return Date(timeInterval: -rhs, since:lhs)
    }
    @inlinable public static func +=(lhs: inout Date, rhs: TimeInterval) {
        return lhs = Date(timeInterval: rhs, since:lhs)
    }
    @inlinable public static func -=(lhs: inout Date, rhs: TimeInterval) {
        return lhs = Date(timeInterval: -rhs, since:lhs)
    }
    
    // MARK: - 可以获取时间差
    @inlinable public static func -(lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
//    public static func -(lhs: Date, rhs: NSDate) -> TimeInterval {
//        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
//    }
}

extension Date {
    
    public init(_ v: String, style: DateFormatter.Style, file:String = #file, line:Int = #line, column:Int = #column) throws {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        if let date = formatter.date(from: v) {
            self = date
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = formatter.date(from: v) {
                self = date
            } else {
                let error:StringError = "日期字符串格式异常[\(v)] at line:\(line) in file:\(file)"
                print(error)
                throw error
            }
        }
    }
    
    public init(_ v: String, dateFormat:String = "yyyy-MM-dd HH:mm:ss", file:String = #file, line:Int = #line, column:Int = #column) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let date = formatter.date(from: v) {
            self = date
        } else {
            let error:StringError = "日期字符串格式异常[\(v)] at line:\(line) in file:\(file)"
            print(error)
            throw error
        }
    }

}

// MARK: - 计算
extension Date {
    public mutating func add(day:Int) {
        let timeInterval = timeIntervalSince1970 + Double(day) * 24 * 3600
        self = Date(timeIntervalSince1970: timeInterval)
    }
    public mutating func add(hour:Int) {
        let timeInterval = timeIntervalSince1970 + Double(hour) * 3600
        self = Date(timeIntervalSince1970: timeInterval)
    }
    public mutating func add(minute:Int) {
        let timeInterval = timeIntervalSince1970 + Double(minute) * 60
        self = Date(timeIntervalSince1970: timeInterval)
    }
    public mutating func add(second:Int) {
        let timeInterval = timeIntervalSince1970 + Double(second)
        self = Date(timeIntervalSince1970: timeInterval)
    }
    public mutating func add(month m:Int) {
        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        comps.month! += m
        
        if let date = Calendar.current.date(from: comps) {
            self = date
        } else {
            let timeInterval = timeIntervalSince1970 + Double(m) * 30 * 24 * 3600
            self = Date(timeIntervalSince1970: timeInterval)
        }
    }
    public mutating func add(year y:Int) {
        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        comps.year! += y
        if let date = Calendar.current.date(from: comps) {
            self = date
        } else {
            let timeInterval = timeIntervalSince1970 + Double(y) * 365 * 24 * 3600
            self = Date(timeIntervalSince1970: timeInterval)
        }
    }
}

// MARK: - DateComponents
extension Date {
    
    var dateComponents:DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday, .era, .nanosecond, .weekOfMonth, .weekOfYear, .weekdayOrdinal, .quarter, .timeZone, .yearForWeekOfYear], from: self)
    }
    
    // for example : let (year, month, day) = date.getDay()
    public func getDay() -> (year:Int, month:Int, day:Int) {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return (comps.year!, comps.month!, comps.day!)
    }
    
    // for example : let (hour, minute, second) = date.getTime()
    public func getTime() -> (hour:Int, minute:Int, second:Int) {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        return (comps.hour!, comps.minute!, comps.second!)
    }
}



extension Date{

    // 闰年
    public var isBissextileYear:Bool {
        let (year, _, _) = getDay()
        return year % 4 == 0
    }
    // 闰月
    public var isFebruary:Bool {
        let (_, month, _) = getDay()
        return month == 2
    }
    
    //是否为今年
    public func isThisYear() -> Bool{
        let calender = Calendar.current
        //获得当前时间的年月日
        let nowCmps = calender.dateComponents([.year], from: Date())
        //获得self的年月日
        let selfCmps = calender.dateComponents([.year], from: self)
        
        return nowCmps.year == selfCmps.year
        
    }
    
    //是否为今天
    public func isToday() -> Bool {
        let calender = Calendar.current
        //获得当前时间的年月日
        let nowCmps = calender.dateComponents([.day,.month,.year], from: Date())
        //获得self的年月日
        let selfCmps = calender.dateComponents([.day,.month,.year], from: self)
        
        return selfCmps.year == nowCmps.year && selfCmps.month == nowCmps.month && selfCmps.day == nowCmps.day
    }
    
    //是否为昨天
    public func isYesterday() -> Bool {
        let nowDate = Date().dateWithYMD()
        let selfDate = self.dateWithYMD()
        //获取差距
        let calender = Calendar.current
        let camps = calender.dateComponents([.day], from: nowDate, to: selfDate)
        
        return camps.day == 1
    }
    
    
    
    
}

extension Date : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = StaticString
    public typealias UnicodeScalarLiteralType = UnicodeScalar
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = (try? Date(value)) ?? Date(timeIntervalSince1970: 0)
    }
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = (try? Date(value.description)) ?? Date(timeIntervalSince1970: 0)
    }
    public init(stringLiteral value: StringLiteralType) {
        self = (try? Date(value.description)) ?? Date(timeIntervalSince1970: 0)
    }
    
}


// MARK: - String
extension Date{
    // 格式化时间
    public func string(withFormat format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt.string(from: self)
    }
    
    // 返回一个只有年月日的时间
    public func dateWithYMD() -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let selfStr = fmt.string(from: self)
        return fmt.date(from: selfStr)!
    }

    // 获取与当前时间的差距
    public func deltaWithNow() -> DateComponents {
        let calender = Calendar.current
        return calender.dateComponents([.hour,.minute,.second], from: self, to: Date())
    }

}

extension Date{

    //MARK:从微博服务端字符串获取日期
    public static func date(fromServer dateString:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.date(from: dateString)!

    }
     //MARK:返回日期的描述文字，1分钟内：刚刚，1小时内：xx分钟前，1天内：HH:mm，昨天：昨天 HH:mm，1年内：MM-dd HH:mm，更早时间：yyyy-MM-dd HH:mm
    public func descriptionDate() -> String {
        let calender = Calendar.current
        var dateFormat = "HH:mm"
        // 如果是一天之内
        if calender.isDateInToday(self) {
            let since = Date().timeIntervalSince(self)
            //一分钟内
            if since < 60.0 {
                return "刚刚"
            }
            if since < 3600.0 {
                return "\(Int(since/60))分钟前"
            }
            return "\(Int(since/3600.0))小时前"
        }
        // 如果是昨天
        if calender.isDateInYesterday(self) {
            dateFormat = "昨天 " + dateFormat
        } else {
            dateFormat = "MM-dd " + dateFormat
            let component = calender.dateComponents([.year], from: self, to: Date())
            if component.year! > 1 {
                dateFormat = "yyyy-" + dateFormat
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.string(from: self)

    }

}

extension TimeInterval {
    
    public var dateSince1970:Date { return Date(timeIntervalSince1970: self) }
    
    public var dateSinceNow:Date { return Date(timeIntervalSinceNow: self) }
}

