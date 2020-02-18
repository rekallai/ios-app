//
//  AnnotationMetadata.swift
//  Rekall
//
//  Created by Ray Hunter on 04/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreLocation

@available(iOS 13.0, *)
class AnnotationMetadata {

    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let floor: Int
    let localImageName: String?
    let remoteImage: URL?
    let isOccupant: Bool
    let canShowVenueDetailsScreen: Bool
    
    init(amenity: Amenity, floor: Int) {
        if amenity.category == .service {
            title = NSLocalizedString("Kiosk", comment: "Name of help point")
        } else {
            title = amenity.title ?? ""
        }
        subtitle = ""
        coordinate = amenity.coordinate
        self.floor = floor
        
        if let category = amenity.category {
            switch category {
            case .restroom:
                localImageName = "MapsNearbyRestrooms"
            case .service:
                localImageName = "MapsNearbyConcierge"
            default:
                localImageName = "MapsNearbyDefault"
                print("ERROR: No available image for amenity category: \(category)")
                break
            }
        } else {
            localImageName = nil
        }
        
        remoteImage = nil
        isOccupant = false
        canShowVenueDetailsScreen = false
    }
    
    init?(occupant: Occupant, floor: Int) {
        title = occupant.title ?? ""
        subtitle = ""
        coordinate = occupant.coordinate
        self.floor = floor
        
        if let venue = Venue.venueOnFloor(floor: floor, coordinate: occupant.coordinate) {
            localImageName = nil
            canShowVenueDetailsScreen = true
            remoteImage = venue.imageUrls?.first
        } else {
            localImageName = "MapsNearbyDefault"
            canShowVenueDetailsScreen = false
            remoteImage = nil
        }

        isOccupant = true
    }
}
