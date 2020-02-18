//
//  OccupantList.swift
//  Rekall
//
//  Created by Ray Hunter on 07/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

@available(iOS 13.0, *)
class OccupantList: NSObject {

    var currentLevel = 0
    var occupants = [Occupant]()
    var allLevels: [Level] = [] // ToDo - Refactor this
    
    func occupantFor(venue: Venue) -> Occupant? {
        guard let venueLocation = venue.location else {
            return nil
        }
        
        return occupantNearestCoordinate(coordinate: venueLocation.coordinate,
                                         in: occupants,
                                         maxDistance: 2)
    }
    
    func occupantNearishCoordinate(coordinate: CLLocationCoordinate2D,
                                   on level: Int) -> Occupant? {

        guard level < allLevels.count else { return nil }
        
        return occupantNearestCoordinate(coordinate: coordinate,
                                         in: allLevels[level].occupants,
                                         maxDistance: 300)
    }
    
    func occupantNearestCoordinate(coordinate: CLLocationCoordinate2D,
                                   in list: [Occupant],
                                   maxDistance: CLLocationDistance) -> Occupant? {
        
        var bestDistance = CLLocationDistance.greatestFiniteMagnitude
        var bestOccupant: Occupant?
        
        let mapPoint = MKMapPoint(coordinate)
        for occupant in list {
            let occupantMapPoint = MKMapPoint(occupant.coordinate)
            let distance = mapPoint.distance(to: occupantMapPoint)
            
            if distance < bestDistance {
                bestDistance = distance
                bestOccupant = occupant
            }
        }
        
        guard bestDistance < maxDistance else {
            return nil
        }
        
        return bestOccupant
    }
}
