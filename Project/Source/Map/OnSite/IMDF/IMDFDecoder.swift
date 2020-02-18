/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class decodes GeoJSON-based IMDF data and returns structured types.
*/

import Foundation
import MapKit

@available(iOS 13.0, *)
protocol IMDFDecodableFeature {
    init(feature: MKGeoJSONFeature) throws
}

enum IMDFError: Error {
    case invalidType
    case invalidData
}

private struct IMDFArchive {
    let baseDirectory: URL
    init(directory: URL) {
        baseDirectory = directory
    }
    
    enum File {
        case address
        case amenity
        case anchor
        case building
        case detail
        case fixture
        case footprint
        case geofence
        case kiosk
        case level
        case manifest
        case occupant
        case opening
        case relationship
        case section
        case unit
        case venue
        
        var filename: String {
            return "\(self).geojson"
        }
    }
    
    func fileURL(for file: File) -> URL {
        return baseDirectory.appendingPathComponent(file.filename)
    }
}

@available(iOS 13.0, *)
class IMDFDecoder {
    private let DEBUG_OCCUPANT_DATA = false
    private let geoJSONDecoder = MKGeoJSONDecoder()
    func decode(_ imdfDirectory: URL) throws -> MapVenue {
        let archive = IMDFArchive(directory: imdfDirectory)
        
        // Decode all the features that need to be rendered.
        let venues = try decodeFeatures(MapVenue.self, from: .venue, in: archive)
        let levels = try decodeFeatures(Level.self, from: .level, in: archive)
        let units = try decodeFeatures(Unit.self, from: .unit, in: archive)
        let openings = try decodeFeatures(Opening.self, from: .opening, in: archive)
        let amenities = try decodeFeatures(Amenity.self, from: .amenity, in: archive)
        let fixtures = try decodeFeatures(Fixture.self, from: .fixture, in: archive)
        let kiosks = try decodeFeatures(Kiosk.self, from: .kiosk, in: archive)
        //let sections = try decodeFeatures(Section.self, from: .section, in: archive)
        
        // Associate levels to venues.
        guard venues.count == 1 else {
            throw IMDFError.invalidData
        }
        let venue = venues[0]
        venue.levelsByOrdinal = Dictionary(grouping: levels, by: { $0.properties.ordinal })
        
        // Associate Units and Opening to levels.
        var firstPassUnits = [Unit]()
        var secondPassUnits = [Unit]()
        let secondPassCategories = [Unit.StylableCategory.elevator.rawValue,
                                    Unit.StylableCategory.escalator.rawValue,
                                    Unit.StylableCategory.stairs.rawValue,
                                    Unit.StylableCategory.restroom.rawValue,
                                    Unit.StylableCategory.restroomMale.rawValue,
                                    Unit.StylableCategory.restroomFemale.rawValue                                    
                                    ]
        units.forEach { unit in
            if secondPassCategories.contains(unit.properties.category) {
                secondPassUnits.append(unit)
            } else {
                //print("First Pass category: \(unit.properties.category)")
                firstPassUnits.append(unit)
            }
        }
        
        if DEBUG_OCCUPANT_DATA {
            levels.forEach { level in
                print("Level id: \(level.identifier) is ordinal: \(level.properties.ordinal)")
            }
        }

        let firstPassUnitsByLevel = Dictionary(grouping: firstPassUnits, by: { $0.properties.levelId })
        let secondPassUnitsByLevel = Dictionary(grouping: secondPassUnits, by: { $0.properties.levelId })
        let openingsByLevel = Dictionary(grouping: openings, by: { $0.properties.levelId })
        let fixturesByLevel = Dictionary(grouping: fixtures, by: { $0.properties.levelId })
        let kiosksByLevel = Dictionary(grouping: kiosks, by: { $0.properties.levelId })
        //let sectionsByLevel = Dictionary(grouping: sections, by: { $0.properties.levelId })
        
        // Associate each Level with its corresponding Units and Openings.
        for level in levels {
            if let firstPassUnitsInLevel = firstPassUnitsByLevel[level.identifier] {
                level.firstPassUnits = firstPassUnitsInLevel
            }
            if let secondPassUnitsInLevel = secondPassUnitsByLevel[level.identifier] {
                level.secondPassUnits = secondPassUnitsInLevel
            }
            if let openingsInLevel = openingsByLevel[level.identifier] {
                level.openings = openingsInLevel
            }
            if let fixturesInLevel = fixturesByLevel[level.identifier] {
                level.fixtures = fixturesInLevel
            }
            if let kiosksInLevel = kiosksByLevel[level.identifier] {
                level.kiosks = kiosksInLevel
            }
            /*if let sectionsInLevel = sectionsByLevel[level.identifier] {
                level.sections = sectionsInLevel
            }*/
        }
        
        // Associate Amenities to the Unit in which they reside.
        let unitsById = units.reduce(into: [UUID: Unit]()) {
            $0[$1.identifier] = $1
        }
        
        for amenity in amenities {
            guard let pointGeometry = amenity.geometry[0] as? MKPointAnnotation else {
                throw IMDFError.invalidData
            }
            
            if let name = amenity.properties.name?.bestLocalizedValue {
                amenity.title = name
                amenity.subtitle = amenity.properties.category.capitalized
            } else {
                amenity.title = amenity.properties.category.capitalized
            }
            
            for unitID in amenity.properties.unitIds {
                let unit = unitsById[unitID]
                unit?.amenities.append(amenity)
            }
            
            amenity.coordinate = pointGeometry.coordinate
            amenity.category = Amenity.Category(rawValue: amenity.properties.category)
        }

        // Occupants (and certain other IMDF features) do not directly contain geometry. Instead, they reference a separate `Anchor` which
        // contains geometry. Occupants should be associated with Units.
        
        try decodeOccupants(units: units, in: archive)
        
        for l in levels {
            l.occupants += l.firstPassUnits.flatMap{$0.occupants}
            l.occupants += l.secondPassUnits.flatMap{$0.occupants}
        }
        
        return venue
    }
    
    private func decodeOccupants(units: [Unit], in archive: IMDFArchive) throws {
        let occupants = try decodeFeatures(Occupant.self, from: .occupant, in: archive)
        let anchors = try decodeFeatures(Anchor.self, from: .anchor, in: archive)
        let unitsById = units.reduce(into: [UUID: Unit]()) {
            $0[$1.identifier] = $1
        }
        let anchorsById = anchors.reduce(into: [UUID: Anchor]()) {
            $0[$1.identifier] = $1
        }
        
        // Resolve the occupants location based on the referenced Anchor, and associating them
        // with their corresponding Unit.
        for occupant in occupants {
            guard let anchor = anchorsById[occupant.properties.anchorId] else {
                throw IMDFError.invalidData
            }
            
            guard let pointGeometry = anchor.geometry[0] as? MKPointAnnotation else {
                throw IMDFError.invalidData
            }
            occupant.coordinate = pointGeometry.coordinate
            
            if let name = occupant.properties.name.bestLocalizedValue {
                occupant.title = name
                occupant.subtitle = occupant.properties.category.capitalized
            } else {
                occupant.title = occupant.properties.category.capitalized
            }
            
            guard let unit = unitsById[anchor.properties.unitId] else {
                continue
            }
            
            if DEBUG_OCCUPANT_DATA {
                print("Occupant \(occupant.title ?? "<no title>") lat: \(occupant.coordinate.latitude) lng: \(occupant.coordinate.longitude), level: \(occupant.unit?.properties.levelId.uuidString ?? "<no uuid>")")
            }
            
            // Associate occupants to units.
            unit.occupants.append(occupant)
            occupant.unit = unit
        }
    }
    
    private func decodeFeatures<T: IMDFDecodableFeature>(_ type: T.Type, from file: IMDFArchive.File, in archive: IMDFArchive) throws -> [T] {
        let fileURL = archive.fileURL(for: file)
        let data = try Data(contentsOf: fileURL)
        let geoJSONFeatures = try geoJSONDecoder.decode(data)
        guard let features = geoJSONFeatures as? [MKGeoJSONFeature] else {
            throw IMDFError.invalidType
        }
        
        let imdfFeatures = try features.map { try type.init(feature: $0) }
        return imdfFeatures
    }
}

