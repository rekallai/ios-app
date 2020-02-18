//
//  Directions.swift
//  Rekall
//
//  Created by Ray Hunter on 15/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import MapKit

class Direction {
    
    enum Action {
        case startingPoint
        case arrived
        case turnLeft
        case turnRight
        case escalatorUp
        case escalatorDown
        case elevatorUp
        case elevatorDown
    }
    
    init(distance: Double, nearbyOccupantName: String?, action: Action, location: MKMapPoint, floor: Int) {
        self.distance = distance
        self.nearbyOccupantName = nearbyOccupantName
        self.action = action
        self.location = location
        self.floor = floor
    }
    
    var distance: Double
    var nearbyOccupantName: String?
    var action: Action
    var location: MKMapPoint
    var floor: Int
    
    func walkingTime() -> Double {
        Distance.walkingtimeInMinutes(distanceInMeters: distance)
    }
    
    func stringRepresentation() -> String {
        
        switch action {
        case .startingPoint:
            return "Starting Point"
        case .arrived:
            return "You have arrived"
        case .turnLeft:
            var directionString = "Turn left"
            if let label = nearbyOccupantName {
                directionString += " at \(label)"
            }
            return directionString
        case .turnRight:
            var directionString = "Turn right"
            if let label = nearbyOccupantName {
                directionString += " at \(label)"
            }
            return directionString
        case .escalatorUp:
            return "Take the escalator up to floor \(floor)"
        case .escalatorDown:
            return "Take the escalator down to floor \(floor)"
        case .elevatorUp:
            return "Take the elevator up to floor \(floor)"
        case .elevatorDown:
            return "Take the elevator down to floor \(floor)"
        }
    }
}

@available(iOS 13.0, *)
protocol DirectionsDelegate: class {
    func currentDirectionUpdated(sender: Directions)
    func destinationReachedIn(sender: Directions)
}

@available(iOS 13.0, *)
class Directions {
    
    let ARRIVED_DELTA = 10.0     // 10 Meters within target location
    weak var delegate: DirectionsDelegate?

    var directions = [Direction]()
    var destinationTitle: String
    var currentDirectionIndex = 0

    init(route: Route){
        destinationTitle = route.destinationTitle
        
        if let firstCoord = route.pathPerFloor[0].1.first {
            directions.append(Direction(distance: 0,
                                        nearbyOccupantName: nil,
                                        action: .startingPoint,
                                        location: firstCoord,
                                        floor: route.pathPerFloor[0].0))
        }
                
        for floorIdx in 0..<route.pathPerFloor.count {
            //print("=== Directions for floor ===")
            
            let floor = route.pathPerFloor[floorIdx]
            let distanceRemainingOnFloor = addFloorDirections(floor: floor.0, points: floor.1)
            
            //
            // Interfloor or termination
            //
            if floorIdx != route.pathPerFloor.count - 1 {
                let nextFloor = route.pathPerFloor[floorIdx + 1]
                guard let nextFloorFirstCoord = nextFloor.1.first else { continue }
                
                let goingUp = nextFloor.0 > floor.0
                let isElevator = route.usesElevators
                let action:Direction.Action = isElevator ? (goingUp ? .elevatorUp : .elevatorDown) :
                                                           (goingUp ? .escalatorUp : .escalatorDown)
                directions.append(Direction(distance: distanceRemainingOnFloor,
                                            nearbyOccupantName: nil,
                                            action: action,
                                            location: nextFloorFirstCoord,
                                            floor: nextFloor.0))
            } else {
                guard let lastCoord = floor.1.last else { continue }

                directions.append(Direction(distance: distanceRemainingOnFloor,
                                            nearbyOccupantName: nil,
                                            action: .arrived,
                                            location: lastCoord,
                                            floor: floor.0))
            }
        }
    }
    
    ///
    ///  Add directions for a floor, return remaining distance at the end
    ///
    func addFloorDirections(floor: Int, points: [MKMapPoint]) -> Double {
        
        guard points.count >= 2 else { return 0.0 }
        
        var distanceSinceLast = 0.0
        
        for i in 1..<points.count - 1 {
            let p1 = points[i - 1]
            let p2 = points[i]
            let p3 = points[i + 1]
            
            distanceSinceLast += p2.distance(to: p1)

            let turnAngle = Self.angle(p1: p1, p2: p2, p3: p3)
            if turnAngle < -40 {
                //print("Left turn - \(turnAngle)")
                directions.append(Direction(distance: distanceSinceLast,
                                            nearbyOccupantName: nil,
                                            action: .turnLeft,
                                            location: p2,
                                            floor: floor))
                distanceSinceLast = 0.0
            } else if turnAngle > 40 {
                //print("Right turn - \(turnAngle)")
                directions.append(Direction(distance: distanceSinceLast,
                                            nearbyOccupantName: nil,
                                            action: .turnRight,
                                            location: p2,
                                            floor: floor))
                distanceSinceLast = 0.0
            } else {
                //print("Continue")
            }
        }
        
        distanceSinceLast += points[points.count - 2].distance(to: points[points.count - 1])
        return distanceSinceLast
    }

    /// Return the angle of change in direction p1 -> p2 -> p3. Straight ahead is 0 degrees, 90 degress left is -90,
    /// 90 degrees right is +90.0
    static func angle(p1: MKMapPoint, p2: MKMapPoint, p3: MKMapPoint) -> Double {
        let v1x = p1.coordinate.longitude - p2.coordinate.longitude
        let v1y = p1.coordinate.latitude - p2.coordinate.latitude
        let v2x = p3.coordinate.longitude - p2.coordinate.longitude
        let v2y = p3.coordinate.latitude - p2.coordinate.latitude
        
        let radians = atan2(v1y, v1x) - atan2(v2y, v2x)
        var degrees = (radians * 180.0 / .pi) - 180.0
        
        while degrees < -180.0 {
            degrees += 360.0
        }
        return degrees
    }
    
    func applyOccupantsToDirections(occupantList: OccupantList) {
        for direction in directions {
            direction.nearbyOccupantName = occupantList.occupantNearishCoordinate(coordinate: direction.location.coordinate,
                                                                                  on: direction.floor)?.title
        }
    }
    
    func totalWalkingTime() -> Int {
        var totalTime = 0.0
        
        for d in directions {
            totalTime += d.walkingTime()
        }
        
        return Int(totalTime)
    }
    
    func textDump() {
        for direction in directions {
            
            var directionString = "After \(direction.distance) "
            
            switch direction.action {
            case .startingPoint:
                directionString = "Starting point"
            case .arrived:
                directionString += "you have arrived"
            case .turnLeft:
                directionString += "turn left"
                if let label = direction.nearbyOccupantName {
                    directionString += " at \(label)"
                }
            case .turnRight:
                directionString += "turn right"
                if let label = direction.nearbyOccupantName {
                    directionString += " at \(label)"
                }
            case .escalatorUp:
                directionString += "take the escalator up to floor \(direction.floor)"
            case .escalatorDown:
                directionString += "take the escalator down to floor \(direction.floor)"
            case .elevatorUp:
                directionString += "take the elevator up to floor \(direction.floor)"
            case .elevatorDown:
                directionString += "take the elevator down to floor \(direction.floor)"
            }
            
            print(directionString)
        }
    }
}


@available(iOS 13.0, *)
extension Directions {
    func locationUpdatedTo(coordinate: CLLocationCoordinate2D, floor: Int?) {
        if let floor = floor {
            while currentDirectionIndex < directions.count - 1 && directions[currentDirectionIndex].floor != floor {
                currentDirectionIndex += 1
            }
        }
        
        let mapPoint = MKMapPoint(coordinate)
        
        var bestIndex = -1
        var bestDistance = CLLocationDistance.greatestFiniteMagnitude
        for i in currentDirectionIndex ..< directions.count {
            let direction = directions[i]
            let distance = direction.location.distance(to: mapPoint)
            
            if distance < bestDistance {
                if let floor = floor {
                    if floor != direction.floor {
                        continue
                    }
                }
                
                bestDistance = distance
                bestIndex = i
            }
        }
        
        guard bestDistance < CLLocationDistance.greatestFiniteMagnitude else {
            return
        }
        
        if bestIndex != currentDirectionIndex {
            currentDirectionIndex = bestIndex
            delegate?.currentDirectionUpdated(sender: self)
        }
        
        //
        // End of route checking
        //
        guard currentDirectionIndex == directions.count - 1 else {
            return
        }
        
         let lastCoord = directions[currentDirectionIndex].location
        
        if lastCoord.distance(to: mapPoint) <= ARRIVED_DELTA {
            delegate?.destinationReachedIn(sender: self)
        }
    }
    
    
    enum WaypointState {
        case currentPosition
        case notVisited
        case visited
    }
    
    func stateForDirection(directionIndex: Int) -> WaypointState {
        if currentDirectionIndex == directionIndex { return .currentPosition }
        if directionIndex < currentDirectionIndex { return .visited }
        return .notVisited
    }
}
