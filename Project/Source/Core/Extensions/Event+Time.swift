//
//  Event+Time.swift
//  Rekall
//
//  Created by Steve on 9/30/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension Event {
    
    func isOpen()->Bool {
        if let start = startsAt, let end = endsAt {
            let range = min(start,end)...max(start,end)
            return range.contains(Date())
        } else { return false }
    }
    
    func isOpenDisplay()->String {
        if isOpen() {
            return NSLocalizedString("Open Now", comment: "label")
        } else {
            return NSLocalizedString("Closed", comment: "label")
        }
    }
    
    func time()->String {
        if let start = startsAt, let end = endsAt {
            return "\(start.shortDayMonthTime()) to \(end.shortDayMonthTime())"
        } else { return "" }
    }
    
    func startsEndsTime()->String {
        if let start = startsAt, let end = endsAt {
            if isOpen() {
                let prefix = NSLocalizedString("Ends at", comment: "label")
                return "\(prefix) \(end.shortDayMonthTime())"
            } else {
                return beforeAfterDisplay(start: start, end: end)
            }
        } else { return "" }
    }
    
    func beforeAfterDisplay(start: Date, end: Date)->String {
        if start > Date() {
            let prefix = NSLocalizedString("Starts at", comment: "label")
            return "\(prefix) \(start.shortDayMonthTime())"
        } else if end < Date() {
            let prefix = NSLocalizedString("Ended at", comment: "label")
            return "\(prefix) \(end.shortDayMonthTime())"
        } else { return "" }
    }
    
}
