/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The decoded representation of an IMDF Amenity feature type.
*/

import Foundation
import MapKit

@available(iOS 13.0, *)
class Amenity: Feature<Amenity.Properties>, MKAnnotation {
    
    enum Category: String {
        case parking
        case stairs
        case elevator
        case escalator
        case drinkingfountain
        case information
        case eatingdrinking
        case restroom
        case firstaid
        case unspecified
        case service
    }
    
    struct Properties: Codable {
        let category: String
        let name: LocalizedName?
        let unitIds: [UUID]
    }
    
    var category: Category?
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var title: String?
    var subtitle: String?
}

// For more information about this class, see: https://register.apple.com/resources/imdf/Amenity/
