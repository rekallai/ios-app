/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Extensions to the IMDF types to enable styling overlays/annotations based on their properties.
*/

import MapKit

@available(iOS 13.0, *)
protocol StylableFeature {
    var geometry: [MKShape & MKGeoJSONObject] { get }
    func configure(overlayRenderer: MKOverlayPathRenderer)
    func configure(annotationView: MKAnnotationView)
}

// Provide default empty implementations for these protocol methods.
@available(iOS 13.0, *)
extension StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {}
    func configure(annotationView: MKAnnotationView) {}
}

@available(iOS 13.0, *)
extension MapVenue: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor(named: "LevelStroke")
        overlayRenderer.fillColor = UIColor(named: "VenueFill")
        overlayRenderer.lineWidth = 2.0
    }
}

@available(iOS 13.0, *)
extension Level: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor(named: "LevelStroke")
        overlayRenderer.lineWidth = 2.0
    }
}

@available(iOS 13.0, *)
extension Unit: StylableFeature {
    // A list of unit categories which we are interested in styling in unique ways. Note: This is not a full list of possible IMDF category names.
    enum StylableCategory: String {
        // Above fixtures
        case elevator
        case escalator
        case stairs
        case restroom
        case restroomMale = "restroom.male"
        case restroomFemale = "restroom.female"

        // Below fixures
        case room
        case nonpublic
        case walkway
        case parking
        case unspecified
        case structure
    }
    
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .elevator, .escalator, .stairs:
                overlayRenderer.fillColor = UIColor(named: "ElevatorFill")
            case .restroom, .restroomMale, .restroomFemale:
                overlayRenderer.fillColor = UIColor(named: "RoomFill")
            case .room:
                overlayRenderer.fillColor = UIColor(named: "RoomFill")
            case .nonpublic:
                overlayRenderer.fillColor = UIColor(named: "NonPublicFill")
            case .walkway:
                overlayRenderer.fillColor = UIColor(named: "WalkwayFill")
            case .parking, .unspecified, .structure:
                overlayRenderer.fillColor = UIColor(named: "DefaultUnitFill")
            }
        } else {
            //print("Unhandled category: \(self.properties.category)")
            overlayRenderer.fillColor = UIColor(named: "DefaultUnitFill")
        }

        overlayRenderer.strokeColor = UIColor(named: "UnitStroke")
        overlayRenderer.lineWidth = 1.0
        
        if occupants.count > 0 {
            overlayRenderer.fillColor = UIColor(named: "UnitOccupiedFill")
        }
    }
}

@available(iOS 13.0, *)
extension Opening: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        // Match the standard unit fill color so the opening lines match the open areas' colors.
        overlayRenderer.strokeColor = UIColor(named: "WalkwayFill")
        overlayRenderer.lineWidth = 2.0
    }
}

@available(iOS 13.0, *)
extension Amenity: StylableFeature {
    private enum StylableCategory: String {
        case restroom
        case service
        case information
        case parking
    }
    
    func configure(annotationView: MKAnnotationView) {
        if let icav = annotationView as? ImageCalloutAnnotationView {
            guard let category = StylableCategory(rawValue: self.properties.category) else {
                print("Unhandled amenity category: \(self.properties.category)")
                return
            }
            switch category {
            case .restroom:
                icav.imageView.image = UIImage(named: "MapsPinRestroom")
            case .service:
                icav.imageView.image = UIImage(named: "MapsPinService")
            default:
                icav.imageView.image = nil
            }
        }
        
        guard let pav = annotationView as? PointAnnotationView else {
            return
        }

        guard let category = StylableCategory(rawValue: self.properties.category) else {
            print("Unhandled amenity category: \(self.properties.category)")
            pav.category = .other
            
            return
        }
        
        switch category {
        case .restroom:
            pav.category = .restroom
        case .service:
            pav.category = .service
        case .information:
            pav.category = .information
        case .parking:
            pav.category = .parking
            //annotationView.backgroundColor = #colorLiteral(red: 0.4470588235, green: 0.8274509804, blue: 1, alpha: 1)
        }
        
        // Most Amenities have lower display priority then Occupants.
    }
}

@available(iOS 13.0, *)
extension Occupant: StylableFeature {
    private enum StylableCategory: String {
        case restaurant
        case shopping
    }

    func configure(annotationView: MKAnnotationView) {
        guard let pav = annotationView as? PointAnnotationView else {
            return
        }

        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .restaurant:
                pav.category = .restaurant
            case .shopping:
                pav.category = .shopping
            }
        } else {
            print("Unhandled occupant category: \(self.properties.category)")
        }

        annotationView.displayPriority = .defaultHigh
    }    
}


@available(iOS 13.0, *)
extension Fixture: StylableFeature {
    private enum StylableCategory: String {
        case vegetation
        case water
        case obstruction
    }
        
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .vegetation:
                overlayRenderer.fillColor = UIColor(named: "VegetationFill")
            case .water:
                overlayRenderer.fillColor = UIColor(named: "WaterFill")
            case .obstruction:
                overlayRenderer.fillColor = UIColor(named: "DefaultUnitFill")
            }
        } else {
            print("Unhandled fixture category: \(self.properties.category)")
        }
    }
}


@available(iOS 13.0, *)
extension Kiosk: StylableFeature {        
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.fillColor = UIColor(named: "DefaultUnitFill")
    }
}


@available(iOS 13.0, *)
extension Section: StylableFeature {
        
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        //print("Unhandled section category: \(self.properties.category)")
        overlayRenderer.fillColor = UIColor.brown

    }
}
