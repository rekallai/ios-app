/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The decoded representation of an IMDF Venue feature type.
*/

import Foundation

@available(iOS 13.0, *)
class MapVenue: Feature<MapVenue.Properties> {
    struct Properties: Codable {
        let category: String
    }
    
    var levelsByOrdinal: [Int: [Level]] = [:]
}

// For more information about this class, see: https://register.apple.com/resources/imdf/Venue/
