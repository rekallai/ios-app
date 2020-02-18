//
//  Section.swift
//  Rekall
//
//  Created by Ray Hunter on 03/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class Section: Feature<Section.Properties> {
    struct Properties: Codable {
        let name: LocalizedName
        let altName: String?
        let levelId: UUID
        let category: String
    }
}
