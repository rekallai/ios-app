//
//  Date+extensions.swift
//  Rekall
//
//  Created by Steve on 7/30/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension Date {
    
    public static func todayYearMonthDay()->String {
        return DateFormatter.yearMonthDayGmt.string(from:Date())
    }
    
    public static func tomorrowYearMonthDay()->String {
        var comps = DateComponents()
        comps.setValue(1, for: .day)
        let tomorrow = Calendar.current.date(byAdding: comps, to: Date())!
        return DateFormatter.yearMonthDayGmt.string(from: tomorrow)
    }
    
    public func hourMinute()->String {
        return DateFormatter.hourMinuteMeridiem.string(from: self)
    }
    
    public func longDayMonth()->String {
        return DateFormatter.longDayMonthDateGmt.string(from: self)
    }
    
    public func shortDayMonthTime()->String {
        return DateFormatter.shortDayMonthTimeGmt.string(from: self)
    }
    
}
