//
//  Event+CoreDataClass.swift
//  
//
//  Created by Ray Hunter on 14/06/2019.
//
//

import Foundation
import CoreData

@objc
public class Event: NSManagedObject, Decodable, DataItem {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tagline
        case createdAt
        case endsAt = "endDate"
        case startsAt = "startDate"
        case updatedAt
        case categories
        case interestTopicIds
        case images = "hero"
        case venue
        case object
        case itemDescription = "description"
        case slug
        
        enum DescriptionKeys: String, CodingKey {
            case fields
            enum FieldKeys: String, CodingKey {
                case plainBody
                enum BodyKeys: String, CodingKey {
                    case text = "en-US"
                }
            }
        }
        
        enum VenueKeys: String, CodingKey {
            case id
        }
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public required init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Event", in: moc) else {
                fatalError("MOC not set in decoder")
        }
        
        super.init(entity: entity, insertInto: moc)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.tagline = try container.decodeIfPresent(String.self, forKey: .tagline)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.endsAt = try container.decodeIfPresent(Date.self, forKey: .endsAt)
        self.startsAt = try container.decodeIfPresent(Date.self, forKey: .startsAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.categories = try container.decodeIfPresent([String].self, forKey: .categories)
        self.interestTopicIds = try container.decodeIfPresent([String].self, forKey: .interestTopicIds)
        
        if let rawImageUrls = try container.decodeIfPresent([String].self, forKey: .images) {
            imageUrls = rawImageUrls.compactMap{ processUrl(raw: $0) }
        }
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        
        //get itemDescription(plainBody) from deep nest
        do {
            let objectContainer = try container.nestedContainer(keyedBy: CodingKeys.DescriptionKeys.self,
                                                                forKey: .itemDescription)
            let fieldContainer = try objectContainer.nestedContainer(keyedBy: CodingKeys.DescriptionKeys.FieldKeys.self,
                                                                     forKey: .fields)
            let bodyContainer = try fieldContainer.nestedContainer(keyedBy: CodingKeys.DescriptionKeys.FieldKeys.BodyKeys.self,
                                                                   forKey: .plainBody)
            itemDescription = try bodyContainer.decodeIfPresent(String.self,
                                                                forKey: .text)
        } catch {}
        
        do {
            let venueContainer = try container.nestedContainer(keyedBy: CodingKeys.VenueKeys.self,
                                                               forKey: .venue)
            venueId = try venueContainer.decodeIfPresent(String.self, forKey: .id)
        } catch {}
    }
    
    // events img urls have leading slashes, which does not load
    func processUrl(raw: String)->URL? {
        let prefix = (raw.prefix(2) == "//") ? "https:" : ""
        return URL(string: "\(prefix)\(raw)")
    }
    
    var itemTag: String? {
        return displayDate
    }
}

