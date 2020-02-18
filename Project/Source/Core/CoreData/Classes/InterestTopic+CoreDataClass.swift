//
//  InterestTopic+CoreDataClass.swift
//  Rekall
//
//  Created by Steve on 6/24/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import CoreData

@objc
public class InterestTopic: NSManagedObject, Decodable {
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "InterestTopic", in: moc) else {
            fatalError("MOC not set in decoder")
        }
        super.init(entity: entity, insertInto: moc)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}
