//
//  VenueShareItemSource.swift
//  Rekall
//
//  Created by Steve on 7/24/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class VenueShareItemSource:NSObject, UIActivityItemSource {
    var venue:Venue?
    let adURL = Environment.shared.shareBaseUrl
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "\(venue?.name ?? "") @ \(Environment.shared.projectName)!"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return URL(string: "\(adURL)/venue/\(venue?.slug ?? "")")
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "\(venue?.name ?? "") @ \(Environment.shared.projectName)!"
    }
    
}
