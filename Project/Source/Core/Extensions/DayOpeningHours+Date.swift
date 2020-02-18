//
//  DayOpeningHours+Date.swift
//  Rekall
//
//  Created by Steve on 7/30/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension DayOpeningHours {
    
    public func openDate()->Date? {
        if let hour = openHour {
            let minute = openMinute ?? 0
            return createDateEST(hour, minute)
        }
        return nil
    }
    
    public func closeDate()->Date? {
        if let hour = closeHour {
            let minute = closeMinute ?? 0
            return createDateEST(hour, minute)
        }
        return nil
    }
    
    public func openDateDisplay()->Date? {
        if let hour = openHour {
            let minute = openMinute ?? 0
            return createDate(hour, minute)
        }
        return nil
    }
    
    public func closeDateDisplay()->Date? {
        if let hour = closeHour {
            let minute = closeMinute ?? 0
            return createDate(hour, minute)
        }
        return nil
    }
    
    func createDate(_ hour: Int,_ minute: Int)->Date? {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
    }
    
    private func createDateEST(_ hour: Int,_ minute: Int)->Date? {
        let cal = Calendar.current
        if let estZone = TimeZone(identifier: "US/Eastern") {
            var comps = cal.dateComponents(in: estZone, from: Date())
            comps.hour = hour
            comps.minute = minute
            comps.second = 0
            return comps.date
        }
        return nil
    }
    
    func fullTime()->String {
        if let start = openDateDisplay()?.hourMinute(),
            let end = closeDateDisplay()?.hourMinute() {
            return "\(start) to \(end)"
        } else { return "" }
    }
    
}
