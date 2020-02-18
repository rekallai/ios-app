//
//  Venue+FeatureFlags.swift
//  Rekall
//
//  Created by Steve on 9/19/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

extension Venue {
    
    func isComingSoon()->Bool {
        return flagsContains(flag: "coming soon")
    }

    func isFeatured()->Bool {
        return flagsContains(flag: "featured")
    }
    
    private func flagsContains(flag: String)->Bool {
        let flags = featuredFlags ?? []
        return flags.contains(where: { (item) -> Bool in
            item.lowercased() == flag.lowercased()
        })
    }
    
}
