//
//  Distance.swift
//  Rekall
//
//  Created by Ray Hunter on 16/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

class Distance: NSObject {
    
    static let shared = Distance()
    
    var userCoordinate: CLLocationCoordinate2D?
    var userFloorLevel: Int?
    
    private func distanceInMetersFromUserTo(location: CLLocation) -> CLLocationDistance {
        guard let userCoordinate = userCoordinate else {
            return 0
        }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        return userLocation.distance(from: location)
    }
    
    func distanceInMetersFromUserTo(location2d: CLLocationCoordinate2D) -> CLLocationDistance {
        let location = CLLocation(latitude: location2d.latitude, longitude: location2d.longitude)
        return distanceInMetersFromUserTo(location: location)
    }
 
    private func distanceStringFromUserTo(location: CLLocation) -> String {
        let distanceInMeters = distanceInMetersFromUserTo(location: location)
        return Self.distanceStringForMeters(distanceInMeters: distanceInMeters)
    }
    
    func distanceStringFromUserTo(location2d: CLLocationCoordinate2D) -> String {
        let location = CLLocation(latitude: location2d.latitude, longitude: location2d.longitude)
        return distanceStringFromUserTo(location: location)
    }
    
    static func distanceStringForMeters(distanceInMeters: CLLocationDistance) -> String {
        let distanceInFeet = Int(distanceInMeters * 3.2808399)
        return (distanceInFeet == 1) ? NSLocalizedString("1 foot", comment: "Distance") :
                                       NSLocalizedString("\(distanceInFeet) feet", comment: "Distance")
    }

    static func walkingtimeInMinutes(distanceInMeters: CLLocationDistance) -> Double {
        let walkingSpeed = 1.3888   // 5km/h in m/sec
        let seconds = distanceInMeters / walkingSpeed
        let minutes = seconds / 60
        return minutes
    }
}
