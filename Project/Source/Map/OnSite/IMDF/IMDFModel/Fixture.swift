//
//  Fixture.swift
//  Rekall
//
//  Created by Ray Hunter on 03/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class Fixture: Feature<Fixture.Properties> {
    struct Properties: Codable {
        let name: String?
        let altName: String?
        let category: String
        let levelId: UUID
        let anchorId: UUID?
    }
}
