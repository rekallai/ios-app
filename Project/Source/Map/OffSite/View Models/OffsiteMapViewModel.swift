//
//  OffsiteMapViewModel.swift
//  Rekall
//
//  Created by Steve on 8/20/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OffsiteMapViewModel: NSObject {

    var onUpdateStarted: (() -> Void)?
    var onUpdateSuccess: (() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    var onLocationGranted: (() -> Void)?
    var onLocationDenied: (() -> Void)?
    
    var routes = [MKRoute]()
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func loadRoutes() {
        if locationAuthorized() {
            self.onUpdateStarted?()
            let request = directionsRequest()
            request.calculate { response, error in
                guard let unResponse = response else {
                    let errMsg = NSLocalizedString("Failed to load routes",
                                                   comment: "Informing user routes could not load")
                    self.onUpdateFailure?(errMsg)
                    return
                }
                self.routes = unResponse.routes
                self.onUpdateSuccess?()
            }
        }
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationAuthorized()->Bool {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                return true
            }
        }
        return false
    }
    
    func locationNotDetermined()->Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .notDetermined
    }
    
    func mapItems()->[MKMapItem] {
        return [userMapItem(), adLocationMapItem()]
    }
    
    private func directionsRequest()->MKDirections {
        let request = MKDirections.Request()
        request.source = userMapItem()
        request.destination = adLocationMapItem()
        request.transportType = .any
        return MKDirections(request: request)
    }
    
    private func adLocationMapItem()->MKMapItem {
        let location = CLLocationCoordinate2D(latitude: 40.811497, longitude: -74.069287)
        let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = NSLocalizedString("\(Environment.shared.projectName)", comment: "Name of location")
        return mapItem
    }
    
    private func userMapItem()->MKMapItem {
        let mapItem = MKMapItem.forCurrentLocation()
        mapItem.name = NSLocalizedString("My Location", comment: "The users current location")
        return mapItem
    }
    
}

extension OffsiteMapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.onLocationGranted?()
        } else if status == .denied || status == .restricted {
            self.onLocationDenied?()
        }
    }
    
}
