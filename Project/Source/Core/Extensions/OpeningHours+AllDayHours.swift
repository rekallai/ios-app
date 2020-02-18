//
//  OpeningHours+AllDayHours.swift
//  Rekall
//
//  Created by Steve on 9/12/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension OpeningHours {
    
    func allDayHours()->[(String, String)] {
        return (projectedDays ?? []).map { (day) -> (String, String) in
            return dayTime(day: day)
        }
    }
    
    func dayTime(day: DayOpeningHours)->(String, String) {
        let name = day.weekday?.localizedCapitalized ?? ""
        let closed = NSLocalizedString("Closed", comment:"Cell label")
        let time = (day.isClosed ?? false) ? closed : day.fullTime()
        return (day:name, time:time)
    }
    
}
