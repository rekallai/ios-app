//
//  OnsiteOffsiteDetector.swift
//  Rekall
//
//  Created by Ray Hunter on 18/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol OnsiteOffsiteDetectorDelegate: class {
    func deviceIsNow(onsite: Bool, sender: OnsiteOffsiteDetector)
}


class OnsiteOffsiteDetector: NSObject {
    
    weak var delegate: OnsiteOffsiteDetectorDelegate?
    
    private(set) var currentlyInsideMall = false
    private var locationManager = CLLocationManager()
    
    static let mallPerimeterCoords = [
        CLLocationCoordinate2D(latitude: 40.804838, longitude: -74.072032), // West bottom, almost south
        CLLocationCoordinate2D(latitude: 40.808333, longitude: -74.072282),
        CLLocationCoordinate2D(latitude: 40.809312, longitude: -74.071967),
        CLLocationCoordinate2D(latitude: 40.811513, longitude: -74.070884),
        CLLocationCoordinate2D(latitude: 40.811716, longitude: -74.070508),  // 5
        CLLocationCoordinate2D(latitude: 40.810944, longitude: -74.068953),
        CLLocationCoordinate2D(latitude: 40.810157, longitude: -74.067783),
        CLLocationCoordinate2D(latitude: 40.811838, longitude: -74.066034),

        CLLocationCoordinate2D(latitude: 40.811859, longitude: -74.065303),
        CLLocationCoordinate2D(latitude: 40.811354, longitude: -74.063800),  // 10

        CLLocationCoordinate2D(latitude: 40.810400, longitude: -74.064039),
        CLLocationCoordinate2D(latitude: 40.809595, longitude: -74.064857),
        CLLocationCoordinate2D(latitude: 40.808521, longitude: -74.067509),
        CLLocationCoordinate2D(latitude: 40.807637, longitude: -74.066500),
        CLLocationCoordinate2D(latitude: 40.804206, longitude: -74.071192)  // Far south
    ]
    
    let mallBoundingPath: CGPath = {
        let path = CGMutablePath()
        
        var pointCount = 0
        for coord in mallPerimeterCoords {
            let point = CGPoint(x: coord.longitude, y: coord.latitude)
            if pointCount == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            
            pointCount += 1
        }
        
        return path
    }()
    
    override init() {
        super.init()
        locationManager.delegate = self
        setupLocationServices()
    }

    func setupLocationServices() {
        locationManager.delegate = self
        
        guard CLLocationManager.locationServicesEnabled(),
              (CLLocationManager.authorizationStatus() == .authorizedAlways ||
               CLLocationManager.authorizationStatus() == .authorizedWhenInUse ) else {
                return
        }
    
        locationManager.startUpdatingLocation()
    }
    
    func mapPolygon() -> MKPolygon {
        let polygon = MKPolygon(coordinates: Self.mallPerimeterCoords, count: Self.mallPerimeterCoords.count)
        return polygon
    }
}


extension OnsiteOffsiteDetector: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        checkIfOnSiteFor(location: location)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    
    func isLocationInsideMall(location: CLLocation) -> Bool {
        let point = CGPoint(x: location.coordinate.longitude, y: location.coordinate.latitude)
        return mallBoundingPath.contains(point)
    }
    
    
    func checkIfOnSiteFor(location: CLLocation) {
        if isLocationInsideMall(location: location) {
            if !currentlyInsideMall {
                currentlyInsideMall = true
                delegate?.deviceIsNow(onsite: true, sender: self)
            }
        } else {
            if currentlyInsideMall {
                currentlyInsideMall = false
                delegate?.deviceIsNow(onsite: false, sender: self)
            }
        }
    }
}
