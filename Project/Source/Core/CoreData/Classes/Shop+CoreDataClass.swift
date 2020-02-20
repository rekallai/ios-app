//
//  Shop+CoreDataClass.swift
//  
//
//  Created by Ray Hunter on 06/06/2019.
//
//

import Foundation
import CoreData
import CoreLocation

@objc
public class Shop: NSManagedObject, Decodable, CDUpdatable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt
        case updatedAt
        case images
        case itemDescription = "description"
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Shop", in: moc) else {
            fatalError("MOC not set in decoder")
        }
        
        super.init(entity: entity, insertInto: moc)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
                
        if let rawImages = try container.decodeIfPresent([RawImage].self, forKey: .images) {
            imageUrls = rawImages.compactMap{ return $0.imageUrl }
        }
        
        itemDescription = try container.decodeIfPresent(String.self, forKey: .itemDescription)
    }
    
    func equivalentObjectComparator() -> ((Shop) -> Bool) {
        return { [id] other in
            return other.id == id
        }
    }
    
    var itemShortDescription: String? { return itemDescription }
    var itemTag: String? { return name }
}
