//
//  RawImage.swift
//  Rekall
//
//  Created by Ray Hunter on 18/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class RawImage: NSObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case filename
        case rawUrl
        case imageHash = "hash"
        case storageType
        case mimeType
        case ownerId
        case createdAt
        case updatedAt
    }
    
    let id: String
    let filename: String
    let rawUrl: String
    let imageHash: String
    let storageType: String
    let mimeType: String
    let ownerId: String
    let createdAt: Date
    let updatedAt: Date
    
    var imageUrl: URL? {
        let urlStr = "\(AppEnvironment.shared.apiBaseUrl)/1/uploads/\(imageHash)/image"
        return URL(string: urlStr)
    }
}
