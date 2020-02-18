//
//  JibestreamRouting.swift
//  Rekall
//
//  Created by Ray Hunter on 09/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

import JMapCoreKit
import JMapRenderingKit
import JMapControllerKit
import JMapUIKit


class JibestreamRouting: NSObject {

    private var jmap: JMap
    private var controller: JMapController?
    private var waypointsByFloor = [String : [JMapWaypoint]]()
    private let floorOrdinalToString = [ "G", "L1", "L2", "L3", "L4" ]

    override init() {
        let options = JMapOptions()
        options.host = Environment.shared.jibeStreamHost
        options.clientId = Environment.shared.jibeStreamClientId
        options.clientSecret = Environment.shared.jibeStreamClientSecret
        options.customerId = Environment.shared.jibeStringCustomerId
        options.venueId = Environment.shared.jibeStreamVenueId
        
        jmap = JMap(options: options)

        super.init()

        jmap.delegate = self
    }
    
    
    func routeToLocation(userCoordinate: CLLocationCoordinate2D,
                         userFloor: Int,
                         targetLocation: CLLocationCoordinate2D,
                         targetFloor: Int,
                         accessibilityRestricted: Bool) -> Route? {
        
        guard let controller = controller else { return nil }
                
        guard floorOrdinalToString.count > userFloor,
              floorOrdinalToString.count > targetFloor else {
                print("ERROR: could not convert floor ordinal to floor string")
                return nil
        }
        
        let userFloorString = floorOrdinalToString[userFloor]
        let targetFloorString = floorOrdinalToString[targetFloor]
        let userWaypoint = waypointForEpsgCoordinate(location: userCoordinate, floor: userFloorString)
        let targetWaypoint = waypointForEpsgCoordinate(location: targetLocation, floor: targetFloorString)
        
        guard let start = userWaypoint,
              let end = targetWaypoint else {
                print("ERROR: Routing failed")
                return nil
        }
        
        controller.clearWayfindingPath()
        let paths = controller.wayfindBetweenWaypoint(start,
                                                      andWaypoint: end,
                                                      withAccessibility: accessibilityRestricted ? 0 : 100,
                                                      withObstacle: nil)
        
        if paths.count == 0 {
            print("ERROR: Empty coordinated after routing")
            return nil
        }
        
        let mapkitPaths = convertPointsToMapkit(paths: paths)
        return Route(pathPerFloor: mapkitPaths, usesElevators: accessibilityRestricted)
    }
    
    
    func routeToJsDestination(userCoordinate: CLLocationCoordinate2D,
                              userFloor: Int?,
                              jsDestinationId: String,
                              accessibilityRestricted: Bool) -> Route? {
        
        guard let controller = controller else { return nil }
        
        guard let destinationInt = Int(jsDestinationId),
              let destination = controller.activeVenue?.destinations?.getById(destinationInt) else {
                print("ERROR: Could not find Jibestreamdestination ")
                return nil
        }
        
        if userFloor == nil {
            print("WARNING: Users' current floor is not known, defaulting to L1 floor")
            // ToDo - log this
        }
        let userFloorInt = userFloor ?? 1
        let userFloorString = floorOrdinalToString[userFloorInt]
        let userWaypoint = waypointForEpsgCoordinate(location: userCoordinate, floor: userFloorString)

        let destinationWaypoints = destination.waypoints
        
        guard let startPoint = userWaypoint,
              let destinationPoints = destinationWaypoints else {
                print("ERROR: Routing failed")
                return nil
        }
        
        controller.clearWayfindingPath()
        let paths = controller.wayfindToClosestWaypoint(in: destinationPoints,
                                                        from: startPoint,
                                                        withAccessibility: accessibilityRestricted ? 0 : 100,
                                                        withObstacle: nil)
        
        if paths.count == 0 {
            print("ERROR: Empty coordinated after routing")
            return nil
        }
        
        let mapkitPaths = convertPointsToMapkit(paths: paths)
        return Route(pathPerFloor: mapkitPaths, usesElevators: accessibilityRestricted)
    }
    
    
    private func waypointForEpsgCoordinate(location: CLLocationCoordinate2D, floor: String) -> JMapWaypoint? {
        
        guard let controller = controller else { return nil }

        let epsgPoint = CGPoint(x: location.longitude, y: location.latitude)
        let localPoint = JMapUtils.convert(epsgPoint,
                                           fromProjection: "EPSG:4326",
                                           toProjection: "jmap:local",
                                           in: controller.activeVenue)
        
        guard let floorWaypoints = waypointsByFloor[floor] else {
            print("ERROR: No stored waypoints for floor: \(floor)")
            return nil
        }
        
        let waypoint = controller.activeVenue?.getClosestWaypoint(in: floorWaypoints,
                                                                  toCoordinate: localPoint)
        
        return waypoint
    }
}

extension JibestreamRouting: JMapDelegate {
    func jmapInitialized(_ error: JMapError?) {
        if let e = error {
            print("Error: \(e)")
            return
        }
        
        controller = jmap.controller
        
        guard let controller = controller else { return }
        
        guard let floors = controller.currentBuilding?.floors?.getAll() else {
            print("ERROR: Can't wayfind - no floors")
            return
        }
        
        for floor in floors {
            print("Found waypoints for floor: \(floor.shortName ?? "<no name>")")
            guard let floorName = floor.shortName else {
                continue
            }
            
            if let waypointsOnFloor = controller.activeVenue?.maps?.getWaypointsBy(floor) {
                waypointsByFloor[floorName] = waypointsOnFloor
            }
        }
    }
    
    
    private func convertPointsToMapkit(paths: [JMapPathPerFloor]) -> [(Int, [MKMapPoint])] {
        
        var result = [(Int, [MKMapPoint])]()
        
        guard let controller = controller else { return result }
                
        for path in paths{
            
            var floor = 0
            var newCoords = [MKMapPoint]()
            
            if let points = path.points as? [JMapASNode]{
                //print("=== FLOOR ===")
                //print("Points: \(points)")
                for point in points {
                    floor = point.z!.intValue / 100
                    //print("\(point.x!), \(point.y!), \(point.z!)")
                    
                    let sourcePoint = CGPoint(x: point.x!.doubleValue, y: point.y!.doubleValue)
                    let convertedPoint = JMapUtils.convert(sourcePoint,
                                                           fromProjection: "jmap:local",
                                                           toProjection: "EPSG:4326",
                                                           in: controller.activeVenue)
                    let location2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(convertedPoint.y),
                                                            longitude: CLLocationDegrees(convertedPoint.x))
                    let mapPoint = MKMapPoint(location2D)
                    newCoords.append(mapPoint)
                    //print("EPSG coord: \(mapPoint.x), \(mapPoint.y)")
                }
            }
            
            if newCoords.count > 0 {
                result.append((floor, newCoords))
            }
        }
        
        return result
    }
}
