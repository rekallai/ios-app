//
//  Venue+CoreDataClass.swift
//  
//
//  Created by Ray Hunter on 06/06/2019.
//
//

import Foundation
import CoreData
import CoreLocation

@objc
class DayOpeningHours: NSObject, Codable, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(weekday, forKey: "weekday")
        aCoder.encode(openHour, forKey: "openHour")
        aCoder.encode(openMinute, forKey: "openMinute")
        aCoder.encode(closeHour, forKey: "closeHour")
        aCoder.encode(closeMinute, forKey: "closeMinute")
        aCoder.encode(isClosed, forKey: "isClosed")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(holidayName, forKey: "holidayName")
        aCoder.encode(comment, forKey: "comment")
        aCoder.encode(date, forKey: "endDate")
        aCoder.encode(dayStr, forKey: "dayStr")
    }
    
    required init?(coder aDecoder: NSCoder) {
        weekday = aDecoder.decodeObject(forKey: "weekday") as? String
        openHour = aDecoder.decodeObject(forKey: "openHour") as? Int
        openMinute = aDecoder.decodeObject(forKey: "openMinute") as? Int
        closeHour = aDecoder.decodeObject(forKey: "closeHour") as? Int
        closeMinute = aDecoder.decodeObject(forKey: "closeMinute") as? Int
        isClosed = aDecoder.decodeObject(forKey: "isClosed") as? Bool
        type = aDecoder.decodeObject(forKey: "type") as? String
        holidayName = aDecoder.decodeObject(forKey: "holidayName") as? String
        comment = aDecoder.decodeObject(forKey: "comment") as? String
        date = aDecoder.decodeObject(forKey: "date") as? Date
        dayStr = aDecoder.decodeObject(forKey: "dayStr") as? String
    }
    
    let weekday:String?
    let openHour: Int?
    let openMinute: Int?
    let closeHour: Int?
    let closeMinute: Int?
    let isClosed: Bool?
    let type:String?
    let holidayName:String?
    let comment:String?
    let date:Date?
    let dayStr:String?
}

@objc
public class OpeningHours: NSObject, Codable, NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(projectedDays, forKey: "projectedDays")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(updatedAt, forKey: "updatedAt")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        projectedDays = aDecoder.decodeObject(forKey: "projectedDays") as? [DayOpeningHours]
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as? Date
        updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Date
    }
    
    let projectedDays:[DayOpeningHours]?
    let createdAt:Date?
    let updatedAt:Date?
}

@objc
public class ContactDetails: NSObject, Codable, NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(phoneNo, forKey: "phoneNo")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(website, forKey: "website")
        aCoder.encode(address, forKey: "address")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        phoneNo = aDecoder.decodeObject(forKey: "phoneNo") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        website = aDecoder.decodeObject(forKey: "website") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
    }
    
    let phoneNo: String?
    let email: String?
    let website: String?
    let address: String?
}

@objc
public class NearbyVenue: NSObject, Codable, NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String
    }
    let id: String?
}

@objc
public class Location: NSObject, Codable, NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(lng, forKey: "lng")
    }
    public required init?(coder aDecoder: NSCoder) {
        lat = aDecoder.decodeDouble(forKey: "lat")
        lng = aDecoder.decodeDouble(forKey: "lng")
    }
    let lat: Double
    let lng: Double
    
    func distanceTo(coordinate: CLLocationCoordinate2D) -> Double {
        let ourLocation = CLLocation(latitude: lat, longitude: lng)
        let theirLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return ourLocation.distance(from: theirLocation)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

@objc
public class Venue: NSManagedObject, Decodable, DataItem, CDUpdatable {
    enum CodingKeys: String, CodingKey {
        case id
        case venueType
        case icon
        case name
        case createdAt
        case updatedAt
        case categories
        case openingHours
        case iosImages
        case images
        case itemDescription = "description"
        case floorLevel
        case location
        case locationDescription
        case jibestreamDestinationId
        case gatewaySupplierId
        case contactDetails
        case accessibilityInfo
        case costIndicator
        case hasTickets
        case attributes
        case nearbyVenues
        case featuredFlags
        case slug
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Venue", in: moc) else {
            fatalError("MOC not set in decoder")
        }
        
        super.init(entity: entity, insertInto: moc)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        venueType = try container.decodeIfPresent(String.self, forKey: .venueType)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        //
        // rawCategoryStrings are not stored - must be used to map to proper categories
        // after decode is finished
        //
        rawCategoryStrings = try container.decodeIfPresent([String].self, forKey: .categories)
        openingHours = try container.decodeIfPresent(OpeningHours.self, forKey: .openingHours)
        
        if let rawImages = try container.decodeIfPresent([RawImage].self, forKey: .iosImages),
        rawImages.count > 0 {
            imageUrls = rawImages.compactMap{ return $0.imageUrl }
        } else if let rawImages = try container.decodeIfPresent([RawImage].self, forKey: .images) {
            imageUrls = rawImages.compactMap{ return $0.imageUrl }
        }
        
        itemDescription = try container.decodeIfPresent(String.self, forKey: .itemDescription)
        floorLevel = try container.decodeIfPresent(Int32.self, forKey: .floorLevel) ?? -1
        location = try container.decodeIfPresent(Location.self, forKey: .location)
        locationDescription = try container.decodeIfPresent(String.self, forKey: .locationDescription)
        jibestreamDestinationId = try container.decodeIfPresent(String.self, forKey: .jibestreamDestinationId)
        gatewaySupplierId = try container.decodeIfPresent(String.self, forKey: .gatewaySupplierId)
        contactDetails = try container.decodeIfPresent(ContactDetails.self, forKey: .contactDetails)
        accessibilityInfo = try container.decodeIfPresent(String.self, forKey: .accessibilityInfo)
        costIndicator = try container.decodeIfPresent(String.self, forKey: .costIndicator)
        hasTickets = try container.decodeIfPresent(Bool.self, forKey: .hasTickets) ?? false
        nearbyVenues = try container.decodeIfPresent([NearbyVenue].self, forKey: .nearbyVenues)
        featuredFlags = try container.decodeIfPresent([String].self, forKey: .featuredFlags)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        comingSoon = isComingSoon() //setting for CoreData sorting w/NSSortDescriptor
    }
    
    public class func load(id:String)->Venue? {
            let fr: NSFetchRequest<Venue> = Venue.fetchRequest()
            fr.predicate = NSPredicate(format: "id == %@", id)
            fr.sortDescriptors = [NSSortDescriptor(key: "importOrdinal", ascending: true)]
            let frc = NSFetchedResultsController(fetchRequest: fr,
                                                 managedObjectContext: ADPersistentContainer.shared.viewContext,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
            do {
                try frc.performFetch()
                guard let venue = frc.fetchedObjects?.first else { return nil }
                return venue
            } catch {
                return nil
            }
    }
    
    static func venuesOnFloor(floor: Int) -> [Venue] {
        assert(Thread.current == Thread.main)

        let fr: NSFetchRequest<Venue> = Venue.fetchRequest()
        fr.predicate = NSPredicate(format: "floorLevel == %d", floor)
        
        do {
            let venues = try ADPersistentContainer.shared.viewContext.fetch(fr)
            return venues
        } catch {
            print("ERROR: Failed to load venues: \(error) ")
            return [Venue]()
        }
    }
    
    static public func venueOnFloor(floor: Int, coordinate: CLLocationCoordinate2D) -> Venue? {
        assert(Thread.current == Thread.main)
        
        var bestDistance: Double = Double.greatestFiniteMagnitude
        var bestVenue: Venue?
        
        let venues = venuesOnFloor(floor: floor)
        for venue in venues {
            guard let location = venue.location else { continue }
            let distance = location.distanceTo(coordinate: coordinate)
            
            if distance < bestDistance {
                bestDistance = distance
                bestVenue = venue
            }
        }
        
        guard bestDistance < 2 else {
            return nil
        }
        
        return bestVenue
    }
    
    
    func equivalentObjectComparator() -> ((Venue) -> Bool) {
        return { [id] other in
            return other.id == id
        }
    }
    
    var itemShortDescription: String? { return itemDescription }
    var itemTag: String? {
        if isComingSoon() {
            return NSLocalizedString("Coming Soon", comment: "Title")
        } else {
            return openCloseEvent()
        }
    }
}
