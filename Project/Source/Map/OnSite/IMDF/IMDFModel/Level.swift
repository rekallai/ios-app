/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The decoded representation of an IMDF Level feature type.
*/

import Foundation

@available(iOS 13.0, *)
class Level: Feature<Level.Properties> {
    struct Properties: Codable {
        let ordinal: Int
        let category: String
        let shortName: LocalizedName
        let outdoor: Bool
        let buildingIds: [String]?
    }
    
    var firstPassUnits: [Unit] = []
    var secondPassUnits: [Unit] = []
    var openings: [Opening] = []
    var fixtures: [Fixture] = []
    var kiosks: [Kiosk] = []
    var sections: [Section] = []
    
    var occupants: [Occupant] = [] // Also in firstPassUnits or secondPassUnits. Only for con
}

// For more information about this class, see: https://register.apple.com/resources/imdf/Level/
