//
//  OpeningHours+VenueTimeStrings.swift
//  Rekall
//
//  Created by Steve on 6/19/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension OpeningHours {
    
    func getNextOpeningOrClosingEventTime() -> String {
        if isOpen() {
            guard let closesAt = closeTime() else { return "" }
            return NSLocalizedString("Closes at \(closesAt)", comment: "Store closing time")
        } else {
            guard let opensAt = openTime() else { return "" }
            return NSLocalizedString("Opens at \(opensAt)", comment: "Store opening time")
        }
    }
    
    func openClosed()->String {
        let open = NSLocalizedString("Open Now", comment: "Cell title")
        let closed = NSLocalizedString("Closed", comment: "Cell title")
        return isOpen() ? open : closed
    }
    
    func isOpen()->Bool {
        if let today = today(),
            let startDate = today.openDate(),
            let endDate = today.closeDate(),
            startDate <= endDate {
            return (startDate ... endDate).contains(Date())
        } else { return false }
    }
    
    func today()->DayOpeningHours? {
        let todayStr = Date.todayYearMonthDay()
        return projectedDays?.first(where:{ $0.dayStr == todayStr })
    }
    
    func tomorrow()->DayOpeningHours? {
        let tomorrowStr = Date.tomorrowYearMonthDay()
        return projectedDays?.first(where:{ $0.dayStr == tomorrowStr })
    }
    
    func closeTime()->String? {
        return today()?.closeDateDisplay()?.hourMinute()
    }
    
    func openTime()->String? {
        if let today = today(),
            let closeDate = today.closeDate() {
            if Date() > closeDate {
                return tomorrow()?.openDateDisplay()?.hourMinute()
            } else {
                return today.openDateDisplay()?.hourMinute()
            }
        } else { return nil }
    }
    
    func fullTimeToday()->String {
        return today()?.fullTime() ?? ""
    }
    
}
