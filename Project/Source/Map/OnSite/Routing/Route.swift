//
//  Directions.swift
//  Rekall
//
//  Created by Ray Hunter on 13/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit


protocol RouteDelegate: class {
    func progressMadeIn(sender: Route)
    func destinationReachedIn(sender: Route)
}


///
///  Encapsulates an indoor route with multiple floors
///
class Route: NSObject {

    weak var delegate: RouteDelegate?
    
    enum WaypointState {
        case currentPosition
        case notVisited
        case visited
    }

    let ARRIVED_DELTA = 8.0     // 8 Meters within target location
    
    // Floor and waypoints
    let pathPerFloor: [(Int, [MKMapPoint])]
    let usesElevators: Bool
    var destinationTitle = NSLocalizedString("Destination", comment: "Route destination")
    private(set) var currentSection = 0
    
    /// Floor ordinal and an array of map points
    init(pathPerFloor: [(Int, [MKMapPoint])], usesElevators: Bool) {
        self.pathPerFloor = pathPerFloor
        self.usesElevators = usesElevators
    }
    
    var spansMultipleFloors: Bool {
        return pathPerFloor.count > 1
    }
    
    var numberOfSections: Int {
        return pathPerFloor.count
    }
    
    var numberOfWaypoints: Int {
        return pathPerFloor.count + 1
    }
    
    func floorForSection(waypoint: Int) -> Int {
        return pathPerFloor[waypoint].0
    }
    
    func waypointsArray() -> [[MKMapPoint]] {
        pathPerFloor.map{ $0.1 }
    }
    
    func waypointsForCurrentSection() -> [MKMapPoint] {
        if currentSection == pathPerFloor.count {
            // Route is completed
            return pathPerFloor[currentSection - 1].1
        }
        
        return pathPerFloor[currentSection].1
    }
    
    func floorForCurrentSection() -> Int {
        if currentSection == pathPerFloor.count {
            return pathPerFloor[currentSection - 1].0
        }
        
        return pathPerFloor[currentSection].0
    }
    
    func walkingTimeForSection(waypoint: Int) -> Double {
        guard let a = pathPerFloor[waypoint].1.first,
              let b = pathPerFloor[waypoint].1.last else {
                return 0
        }
        
        let distance = a.distance(to: b)
        return Distance.walkingtimeInMinutes(distanceInMeters: distance)
    }
    
    func totalWalkingTime() -> Double {
        let distance = distanceInMeters
        return Distance.walkingtimeInMinutes(distanceInMeters: distance)
    }
    
    var distanceInMeters: CLLocationDistance {
        var totalDistance: CLLocationDistance = 0.0
        
        for floor in pathPerFloor {
            for i in 0..<floor.1.count - 1 {
                totalDistance += floor.1[i].distance(to: floor.1[i+1])
            }
        }
        
        return totalDistance
    }
        
    func stateForWaypoint(waypoint: Int) -> WaypointState {
        if currentSection == waypoint { return .currentPosition }
        if waypoint < currentSection { return .visited }
        return .notVisited
    }
    
    func locationChangedTo(coordinate: CLLocationCoordinate2D) {
        // Only update coordinate if we're on the last floor
        guard currentSection == pathPerFloor.count - 1,
            let lastCoord = pathPerFloor[currentSection].1.last else {
                return
        }
        
        let posMkMapPoint = MKMapPoint(coordinate)
        if lastCoord.distance(to: posMkMapPoint) <= ARRIVED_DELTA {
            currentSection += 1
            delegate?.destinationReachedIn(sender: self)
        }
    }
    
    /// Returns true if the change results in progress in the route
    func floorChangedTo(floorLevel: Int) -> Bool {
        
        // Can we progress?
        guard currentSection < pathPerFloor.count - 1 else {
            return false
        }
        
        // Have we progressed?
        guard pathPerFloor[currentSection + 1].0 == floorLevel else {
            return false
        }
        
        currentSection += 1
        
        delegate?.progressMadeIn(sender: self)
        
        return true
    }
}
