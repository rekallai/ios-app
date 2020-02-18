//
//  Venue+Details.swift
//  Rekall
//
//  Created by Steve on 7/1/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension Venue {
    
    func openCloseEvent()->String {
        guard let hours = openingHours else { return "" }
        return hours.getNextOpeningOrClosingEventTime()
    }
    
    func nearbyIds()->[String] {
        guard let nearby = nearbyVenues else { return [] }
        return nearby.compactMap({ $0.id })
    }
    
}
