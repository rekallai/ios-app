//
//  MapKit+Extensions.swift
//  Rekall
//
//  Created by Steve on 8/21/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import MapKit

extension MKRoute {

    func transportName()->String {
        switch transportType {
        case .automobile:
            return "Driving"
        case .transit:
            return "Transit"
        case .walking:
            return "Walking"
        default:
            return "Any"
        }
    }
    
    func directionsMode()->String {
        switch transportType {
        case .automobile:
            return MKLaunchOptionsDirectionsModeDriving
        case .transit:
            return MKLaunchOptionsDirectionsModeTransit
        case .walking:
            return MKLaunchOptionsDirectionsModeWalking
        default:
            return MKLaunchOptionsDirectionsModeDefault
        }
    }
    
    func miles()->Double {
        let metersInMile = 1609.34
        return (distance/metersInMile).rounded()
    }
    
}
